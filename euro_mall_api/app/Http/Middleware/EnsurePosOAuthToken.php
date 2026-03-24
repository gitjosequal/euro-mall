<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Laravel\Passport\Token;
use Lcobucci\JWT\Encoding\JoseEncoder;
use Lcobucci\JWT\Signer\Key\InMemory;
use Lcobucci\JWT\Signer\Rsa\Sha256;
use Lcobucci\JWT\Token\Parser;
use Lcobucci\JWT\Validation\Constraint\SignedWith;
use Lcobucci\JWT\Validation\Validator;
use Symfony\Component\HttpFoundation\Response;

class EnsurePosOAuthToken
{
    public function handle(Request $request, Closure $next, string $requiredScope): Response
    {
        $bearer = $request->bearerToken();
        if (! $bearer) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $publicKeyPath = storage_path('oauth-public.key');
        if (! file_exists($publicKeyPath)) {
            return response()->json(['message' => 'Server misconfigured.'], 500);
        }

        try {
            $parser = new Parser(new JoseEncoder());
            $token = $parser->parse($bearer);

            $publicKey = InMemory::file($publicKeyPath);
            $validator = new Validator();
            $constraint = new SignedWith(new Sha256(), $publicKey);

            if (! $validator->validate($token, $constraint)) {
                return response()->json(['message' => 'Invalid token signature.'], 401);
            }

            $claims = $token->claims();

            $exp = $claims->get('exp');
            if ($exp instanceof \DateTimeImmutable && $exp < new \DateTimeImmutable()) {
                return response()->json(['message' => 'Token expired.'], 401);
            }

            $scopes = $claims->get('scopes', []);
            if (! is_array($scopes) || ! in_array($requiredScope, $scopes, true)) {
                return response()->json(['message' => 'Missing required scope.'], 403);
            }

            $jti = $claims->get('jti');
            if ($jti) {
                $dbToken = Token::query()->find($jti);
                if (! $dbToken || $dbToken->revoked) {
                    return response()->json(['message' => 'Token revoked.'], 401);
                }
            }
        } catch (\Throwable) {
            return response()->json(['message' => 'Invalid token.'], 401);
        }

        return $next($request);
    }
}
