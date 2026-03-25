<?php

namespace App\Filament\Widgets;

use App\Models\LoyaltyVoucherRedemption;
use App\Models\PosInvoice;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class OverviewStatsWidget extends StatsOverviewWidget
{
    protected static ?int $sort = -2;

    protected ?string $heading = 'Overview';

    /**
     * @return array<Stat>
     */
    protected function getStats(): array
    {
        $members = User::query()->count();
        $pointsLiability = (int) User::query()->sum('current_points');
        $redemptions = LoyaltyVoucherRedemption::query()->count();
        $posInvoices = PosInvoice::query()->count();

        $topBranch = PosInvoice::query()
            ->select('branch_code', DB::raw('count(*) as c'))
            ->groupBy('branch_code')
            ->orderByDesc('c')
            ->first();

        $branchLabel = $topBranch
            ? (string) $topBranch->branch_code.' ('.(int) $topBranch->c.')'
            : '—';

        return [
            Stat::make('Members', number_format($members)),
            Stat::make('Points liability (sum)', number_format($pointsLiability)),
            Stat::make('Voucher redemptions', number_format($redemptions)),
            Stat::make('POS invoices', number_format($posInvoices)),
            Stat::make('Top POS branch (count)', $branchLabel),
        ];
    }
}
