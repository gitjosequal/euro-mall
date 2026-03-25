<?php

namespace Tests\Feature;

use App\Models\CustomerOrder;
use App\Models\LoyaltyLedger;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberActivityFeedTest extends TestCase
{
    use RefreshDatabase;

    protected function makeMember(string $phone): User
    {
        return User::query()->create([
            'name' => 'Member',
            'email' => $phone.'@test.euromall.app',
            'password' => bcrypt('secret'),
            'phone' => $phone,
            'gender' => 'other',
            'tier_name' => 'Silver',
            'current_points' => 100,
            'next_tier_points' => 4000,
            'tier_progress' => 0,
            'points_earned_today' => 0,
        ]);
    }

    public function test_orders_endpoint_merges_ledger_and_customer_orders(): void
    {
        $user = $this->makeMember('962711100001');

        LoyaltyLedger::query()->create([
            'user_id' => $user->id,
            'source_type' => 'pos_invoice',
            'source_id' => '1',
            'transaction_type' => 'earn',
            'amount' => 50.00,
            'points_delta' => 10,
            'balance_after' => 100,
            'meta' => [],
        ]);

        CustomerOrder::query()->create([
            'user_id' => $user->id,
            'title' => 'Mall purchase',
            'ordered_at' => now()->subHour(),
            'amount' => 20.00,
            'points' => 5,
            'earned' => true,
        ]);

        Sanctum::actingAs($user);

        $res = $this->getJson('/api/v1/orders?locale=en');
        $res->assertOk();
        $res->assertJsonStructure([
            'data',
            'meta' => ['currency_symbol', 'currency_code'],
        ]);

        $ids = collect($res->json('data'))->pluck('id')->map(fn ($id) => (string) $id);
        $this->assertTrue($ids->contains(fn (string $id) => str_starts_with($id, 'ledger_')));
        $this->assertTrue($ids->contains(fn (string $id) => str_starts_with($id, 'order_')));
    }

    public function test_dashboard_includes_currency_and_ledger_recent(): void
    {
        $user = $this->makeMember('962711100002');

        LoyaltyLedger::query()->create([
            'user_id' => $user->id,
            'source_type' => 'pos_invoice',
            'source_id' => '9',
            'transaction_type' => 'earn',
            'amount' => 10.00,
            'points_delta' => 3,
            'balance_after' => 100,
            'meta' => [],
        ]);

        Sanctum::actingAs($user);

        $res = $this->getJson('/api/v1/home/dashboard?locale=en');
        $res->assertOk();
        $res->assertJsonPath('data.currency_symbol', 'JD');
        $res->assertJsonPath('data.currency_code', 'JOD');

        $recent = $res->json('data.recent_transactions');
        $this->assertIsArray($recent);
        $this->assertNotEmpty($recent);
        $this->assertStringStartsWith('ledger_', (string) $recent[0]['id']);
    }
}
