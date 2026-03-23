<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Faq;

class FaqController extends Controller
{
    public function index()
    {
        $locale = request('locale', 'en') === 'ar' ? 'ar' : 'en';
        $items = Faq::query()->orderBy('sort_order')->orderBy('id')->get();

        return response()->json([
            'data' => $items->map(function (Faq $f) use ($locale) {
                return [
                    'id' => (string) $f->id,
                    'question' => $locale === 'ar' ? $f->question_ar : $f->question_en,
                    'answer' => $locale === 'ar' ? $f->answer_ar : $f->answer_en,
                ];
            })->values(),
        ]);
    }
}
