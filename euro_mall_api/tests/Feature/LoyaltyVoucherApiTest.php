<?php

namespace Tests\Feature;

use App\Http\Middleware\EnsurePosOAuthToken;
use App\Models\LoyaltyRedemptionRule;
use App\Models\LoyaltyVoucher;
use App\Models\LoyaltyVoucherRedemption;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LoyaltyVoucherApiTest extends TestCase
{
    use RefreshDatabase;

    protected function makeVoucher(string $code, bool $active = true): LoyaltyVoucher
    {
        return LoyaltyVoucher::query()->create([
            'title_en' => 'Title',
            'title_ar' => 'عنوان',
            'description_en' => 'Desc',
            'description_ar' => 'وصف',
            'is_percentage' => false,
            'value' => 10,
            'expires_at' => now()->addMonth(),
            'code' => $code,
            'minimum_spend' => null,
            'is_active' => $active,
        ]);
    }

    protected function makeMember(string $phone, int $points = 0): User
    {
        return User::query()->create([
            'name' => 'Member',
            'email' => $phone.'@test.euromall.app',
            'password' => bcrypt('secret'),
            'phone' => $phone,
            'gender' => 'other',
            'tier_name' => 'Silver',
            'current_points' => $points,
            'next_tier_points' => 4000,
            'tier_progress' => 0,
            'points_earned_today' => 0,
        ]);
    }

    public function test_guest_voucher_index_lists_only_catalog_vouchers(): void
    {
        $public = $this->makeVoucher('PUB');
        $restricted = $this->makeVoucher('RES');
        $restricted->assignedUsers()->attach($this->makeMember('962700000001')->id);

        $res = $this->getJson('/api/v1/vouchers');

        $res->assertOk();
        $ids = collect($res->json('data'))->pluck('id')->all();
        $this->assertContains((string) $public->id, $ids);
        $this->assertNotContains((string) $restricted->id, $ids);
    }

    public function test_member_sees_catalog_and_own_assigned_vouchers_only(): void
    {
        $public = $this->makeVoucher('PUB2');
        $restricted = $this->makeVoucher('RES2');
        $alice = $this->makeMember('962700000002');
        $bob = $this->makeMember('962700000003');
        $restricted->assignedUsers()->attach($alice->id);

        Sanctum::actingAs($bob);
        $bobIds = collect($this->getJson('/api/v1/vouchers')->json('data'))->pluck('id')->all();
        $this->assertContains((string) $public->id, $bobIds);
        $this->assertNotContains((string) $restricted->id, $bobIds);

        Sanctum::actingAs($alice);
        $aliceIds = collect($this->getJson('/api/v1/vouchers')->json('data'))->pluck('id')->all();
        $this->assertContains((string) $public->id, $aliceIds);
        $this->assertContains((string) $restricted->id, $aliceIds);
    }

    public function test_redeem_deducts_points_per_active_rule(): void
    {
        LoyaltyRedemptionRule::query()->create([
            'name' => 'Default',
            'points_required' => 40,
            'value_amount' => 0,
            'is_percentage' => false,
            'is_active' => true,
        ]);

        $v = $this->makeVoucher('R40');
        $user = $this->makeMember('962700000004', 100);
        Sanctum::actingAs($user);

        $this->postJson("/api/v1/vouchers/{$v->id}/redeem")->assertOk();

        $user->refresh();
        $this->assertSame(60, (int) $user->current_points);
        $this->assertTrue(LoyaltyVoucherRedemption::query()
            ->where('user_id', $user->id)
            ->where('loyalty_voucher_id', $v->id)
            ->exists());
    }

    public function test_pos_consume_matches_app_points_and_redemption(): void
    {
        $this->withoutMiddleware(EnsurePosOAuthToken::class);

        LoyaltyRedemptionRule::query()->create([
            'name' => 'Default',
            'points_required' => 25,
            'value_amount' => 0,
            'is_percentage' => false,
            'is_active' => true,
        ]);

        $v = $this->makeVoucher('POS1');
        $user = $this->makeMember('962700000005', 80);

        $res = $this->postJson('/api/v1/pos/vouchers/validate', [
            'voucher_code' => 'POS1',
            'customer_phone' => $user->phone,
            'consume' => true,
        ]);

        $res->assertOk();
        $res->assertJsonPath('data.consumed', true);
        $res->assertJsonPath('data.points_balance', 55);

        $user->refresh();
        $this->assertSame(55, (int) $user->current_points);
        $this->assertTrue(LoyaltyVoucherRedemption::query()
            ->where('user_id', $user->id)
            ->where('loyalty_voucher_id', $v->id)
            ->exists());
    }
}
