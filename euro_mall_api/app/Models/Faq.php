<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Faq extends Model
{
    protected $fillable = [
        'sort_order',
        'question_en',
        'question_ar',
        'answer_en',
        'answer_ar',
    ];
}
