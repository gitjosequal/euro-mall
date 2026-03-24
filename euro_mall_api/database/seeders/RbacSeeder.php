<?php

namespace Database\Seeders;

use App\Models\PosClient;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Laravel\Passport\ClientRepository;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RbacSeeder extends Seeder
{
    public function run(): void
    {
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        $permissions = [
            'admin.access',
            'pos.write_invoices',
            'pos.validate_voucher',
        ];
        foreach ($permissions as $perm) {
            Permission::findOrCreate($perm, 'web');
        }

        $admin = Role::findOrCreate('admin', 'web');
        $ops = Role::findOrCreate('ops', 'web');
        $marketing = Role::findOrCreate('marketing', 'web');

        $admin->givePermissionTo($permissions);
        $ops->givePermissionTo(['admin.access', 'pos.write_invoices', 'pos.validate_voucher']);
        $marketing->givePermissionTo(['admin.access']);

        $seedAdmin = User::query()->firstOrCreate(
            ['email' => 'admin@euromall.test'],
            [
                'name' => 'Admin',
                'phone' => '+962790000001',
                'password' => Hash::make('password'),
                'gender' => 'other',
                'tier_name' => 'Silver',
                'current_points' => 0,
                'next_tier_points' => 4000,
                'tier_progress' => 0,
                'points_earned_today' => 0,
            ]
        );
        $seedAdmin->assignRole('admin');

        /** @var ClientRepository $clients */
        $clients = app(ClientRepository::class);
        $client = \Laravel\Passport\Client::query()->where('name', 'POS Default Client')->first();
        if (! $client) {
            $created = $clients->createClientCredentialsGrantClient('POS Default Client');
            PosClient::query()->updateOrCreate(
                ['oauth_client_id' => (string) $created->id],
                ['name' => 'Default POS', 'branch_code' => 'ABDOUN', 'is_active' => true]
            );
            if ($this->command) {
                $this->command->info('POS OAuth client created: id='.$created->id.' secret='.$created->plainSecret);
            }
        }
    }
}
