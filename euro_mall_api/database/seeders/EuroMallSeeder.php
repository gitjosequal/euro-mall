<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\CmsPage;
use App\Models\CustomerOrder;
use App\Models\Faq;
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

        $user = User::query()->firstOrCreate(
            ['email' => 'member@euromall.test'],
            [
                'name' => 'Demo Member',
                'password' => Hash::make('password'),
                'phone' => '+962 79 000 0000',
                'gender' => 'female',
                'dob' => '1995-04-12',
                'tier_name' => 'Silver',
            ]
        );

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

        $user->tokens()->delete();
        $token = $user->createToken('mobile-app')->plainTextToken;

        if ($this->command) {
            $this->command->info('Demo user: member@euromall.test / password');
            $this->command->info('Sanctum token (paste into app prefs for testing): '.$token);
        }
    }
}
