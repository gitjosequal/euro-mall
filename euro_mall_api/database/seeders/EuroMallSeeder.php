<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\CmsPage;
use App\Models\CustomerOrder;
use App\Models\Faq;
use App\Models\LoyaltyOffer;
use App\Models\LoyaltyPointRule;
use App\Models\LoyaltyRedemptionRule;
use App\Models\LoyaltyTier;
use App\Models\LoyaltyVoucher;
use App\Models\MallBranch;
use App\Models\NotificationPreference;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class EuroMallSeeder extends Seeder
{
    public function run(): void
    {
        AppSetting::query()->updateOrCreate(
            ['id' => 1],
            [
                'support_phone' => '+962 6 000 0000',
                'developer_name' => 'Josequal',
                'developer_url' => 'https://www.josequal.com',
                'display_version' => '',
                'social_links' => [
                    ['label' => 'Instagram', 'url' => 'https://instagram.com/', 'icon' => 'instagram'],
                    ['label' => 'Facebook', 'url' => 'https://facebook.com/', 'icon' => 'facebook'],
                ],
            ]
        );

        $pages = [
            [
                'slug' => 'terms',
                'title_en' => 'Terms & conditions',
                'title_ar' => 'الشروط والأحكام',
                'body_en' => "# Terms\n\nEdit this text in **cms_pages** in the admin database.",
                'body_ar' => "# الشروط\n\nعدّل هذا النص من لوحة الإدارة.",
            ],
            [
                'slug' => 'privacy',
                'title_en' => 'Privacy policy',
                'title_ar' => 'سياسة الخصوصية',
                'body_en' => "# Privacy\n\nManage this content in the backend CMS.",
                'body_ar' => "# الخصوصية\n\nأدار المحتوى من لوحة التحكم.",
            ],
            [
                'slug' => 'about',
                'title_en' => 'About us',
                'title_ar' => 'من نحن',
                'body_en' => "# Euro Mall\n\nTell your story here (Markdown).",
                'body_ar' => "# يورو مول\n\nاكتب قصتكم هنا.",
            ],
            [
                'slug' => 'points_schema',
                'title_en' => 'Points program',
                'title_ar' => 'برنامج النقاط',
                'body_en' => "# How points work\n\n1. Earn on purchases.\n2. Redeem for rewards.\n\n_Edit in cms_pages.slug = points_schema_.",
                'body_ar' => "# النقاط\n\n١. اكسب عند الشراء.\n٢. استبدل المكافآت.",
            ],
        ];

        foreach ($pages as $p) {
            CmsPage::query()->updateOrCreate(
                ['slug' => $p['slug']],
                $p
            );
        }

        Faq::query()->firstOrCreate(
            ['question_en' => 'How do I earn points?'],
            [
                'sort_order' => 1,
                'question_ar' => 'كيف أجمع النقاط؟',
                'answer_en' => 'Present your member QR or phone number at participating stores.',
                'answer_ar' => 'اعرض رمز العضوية أو رقم هاتفك في المتاجر المشاركة.',
            ]
        );

        $this->seedCatalog();
        $this->seedRules();

        $user = User::query()->firstOrCreate(
            ['email' => 'member@euromall.test'],
            [
                'name' => 'Demo Member',
                'password' => Hash::make('password'),
                'phone' => '+962790000000',
                'gender' => 'female',
                'dob' => '1995-04-12',
                'tier_name' => 'Silver',
                'current_points' => 2650,
                'next_tier_points' => 4000,
                'tier_progress' => 0.66,
                'points_earned_today' => 120,
            ]
        );

        $user->update([
            'phone' => '+962790000000',
            'current_points' => 2650,
            'next_tier_points' => 4000,
            'tier_progress' => 0.66,
            'points_earned_today' => 120,
        ]);

        NotificationPreference::query()->firstOrCreate(
            ['user_id' => $user->id],
            ['push_marketing' => true, 'push_orders' => true, 'email_digest' => false]
        );

        CustomerOrder::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'title' => 'Euro Mall — demo purchase',
            ],
            [
                'ordered_at' => now()->subDay(),
                'amount' => 42.50,
                'points' => 43,
                'earned' => true,
            ]
        );

        CustomerOrder::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'title' => 'Euro Mall — Abdoun',
            ],
            [
                'ordered_at' => now()->subDays(1),
                'amount' => 120.50,
                'points' => 120,
                'earned' => true,
            ]
        );

        CustomerOrder::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'title' => 'Voucher redemption',
            ],
            [
                'ordered_at' => now()->subDays(3),
                'amount' => -20,
                'points' => -200,
                'earned' => false,
            ]
        );

        $user->tokens()->delete();
        $token = $user->createToken('mobile-app')->plainTextToken;

        if ($this->command) {
            $this->command->info('Demo user: member@euromall.test / password (web) or phone +962790000000 — POST auth/otp/send then verify with OTP from cache (fixed mode: '.config('euromall.otp_code').')');
            $this->command->info('Sanctum token: '.$token);
        }
    }

    protected function seedCatalog(): void
    {
        LoyaltyVoucher::query()->updateOrCreate(
            ['code' => 'FASH10'],
            [
                'title_en' => '10% off fashion',
                'title_ar' => 'خصم 10٪ على الأزياء',
                'description_en' => 'Valid on fashion & accessories.',
                'description_ar' => 'صالح على الأزياء والإكسسوارات.',
                'is_percentage' => true,
                'value' => 10,
                'expires_at' => now()->addDays(12),
                'minimum_spend' => 25,
                'is_active' => true,
            ]
        );

        LoyaltyVoucher::query()->updateOrCreate(
            ['code' => 'EAT15'],
            [
                'title_en' => 'JD 15 dining voucher',
                'title_ar' => 'قسيمة مطاعم 15 دينار',
                'description_en' => 'Redeem at any Euro Mall food outlet.',
                'description_ar' => 'استبدل في أي مطعم في يورو مول.',
                'is_percentage' => false,
                'value' => 15,
                'expires_at' => now()->addDays(3),
                'minimum_spend' => 50,
                'is_active' => true,
            ]
        );

        LoyaltyVoucher::query()->updateOrCreate(
            ['code' => 'COFFEEUP'],
            [
                'title_en' => 'Free coffee upgrade',
                'title_ar' => 'ترقية قهوة مجانية',
                'description_en' => 'Upgrade to any large size.',
                'description_ar' => 'ترقية إلى أي حجم كبير.',
                'is_percentage' => false,
                'value' => 0,
                'expires_at' => now()->subDay(),
                'minimum_spend' => null,
                'is_active' => true,
            ]
        );

        LoyaltyOffer::query()->updateOrCreate(
            ['title_en' => 'Double points weekend'],
            [
                'title_ar' => 'نقاط مضاعفة في نهاية الأسبوع',
                'subtitle_en' => 'Earn 2x points on all stores this Friday & Saturday.',
                'subtitle_ar' => 'اكسب ضعف النقاط الجمعة والسبت.',
                'badge_en' => 'Limited',
                'badge_ar' => 'محدود',
                'image_url' => null,
                'expires_at' => now()->addDays(2),
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        LoyaltyOffer::query()->updateOrCreate(
            ['title_en' => 'Beauty flash sale'],
            [
                'title_ar' => 'تخفيضات الجمال',
                'subtitle_en' => 'Up to 30% off selected brands.',
                'subtitle_ar' => 'حتى 30٪ على ماركات مختارة.',
                'badge_en' => 'New',
                'badge_ar' => 'جديد',
                'image_url' => null,
                'expires_at' => null,
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        LoyaltyOffer::query()->updateOrCreate(
            ['title_en' => 'Cinema & snacks bundle'],
            [
                'title_ar' => 'سينما + وجبات خفيفة',
                'subtitle_en' => 'Save JD 5 on every ticket + snack combo.',
                'subtitle_ar' => 'وفر 5 دنانير على التذكرة + الوجبة.',
                'badge_en' => 'Bundle',
                'badge_ar' => 'حزمة',
                'image_url' => null,
                'expires_at' => null,
                'sort_order' => 3,
                'is_active' => true,
            ]
        );

        MallBranch::query()->updateOrCreate(
            ['phone' => '+962 6 555 1111'],
            [
                'name_en' => 'Abdoun',
                'name_ar' => 'عبدون',
                'address_en' => 'Abdoun Circle, Amman',
                'address_ar' => 'دوار عبدون، عمان',
                'hours_en' => '10:00 - 22:00',
                'hours_ar' => '10:00 - 22:00',
                'latitude' => 31.9497,
                'longitude' => 35.9327,
                'open_now' => true,
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        MallBranch::query()->updateOrCreate(
            ['phone' => '+962 6 444 2222'],
            [
                'name_en' => 'Downtown',
                'name_ar' => 'وسط البلد',
                'address_en' => 'King Hussein Street, Amman',
                'address_ar' => 'شارع الملك حسين، عمان',
                'hours_en' => '09:00 - 23:00',
                'hours_ar' => '09:00 - 23:00',
                'latitude' => 31.9515,
                'longitude' => 35.9396,
                'open_now' => false,
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        MallBranch::query()->updateOrCreate(
            ['phone' => '+962 6 222 3333'],
            [
                'name_en' => 'Airport Road',
                'name_ar' => 'طريق المطار',
                'address_en' => 'Queen Alia Airport Road',
                'address_ar' => 'طريق الملكة علياء الدولي',
                'hours_en' => '24/7',
                'hours_ar' => '24/7',
                'latitude' => 31.9729,
                'longitude' => 35.9916,
                'open_now' => true,
                'sort_order' => 3,
                'is_active' => true,
            ]
        );
    }

    protected function seedRules(): void
    {
        LoyaltyTier::query()->updateOrCreate(
            ['name' => 'Silver'],
            ['min_points' => 0, 'max_points' => 3999, 'sort_order' => 1, 'is_active' => true]
        );
        LoyaltyTier::query()->updateOrCreate(
            ['name' => 'Gold'],
            ['min_points' => 4000, 'max_points' => 9999, 'sort_order' => 2, 'is_active' => true]
        );
        LoyaltyTier::query()->updateOrCreate(
            ['name' => 'Platinum'],
            ['min_points' => 10000, 'max_points' => null, 'sort_order' => 3, 'is_active' => true]
        );

        LoyaltyPointRule::query()->updateOrCreate(
            ['name' => 'Default earn rule'],
            [
                'amount_per_point' => 1,
                'points_per_unit' => 1,
                'max_points_per_transaction' => null,
                'is_active' => true,
            ]
        );

        LoyaltyRedemptionRule::query()->updateOrCreate(
            ['name' => 'Default redemption'],
            [
                'points_required' => 100,
                'value_amount' => 1,
                'is_percentage' => false,
                'is_active' => true,
            ]
        );
    }
}
