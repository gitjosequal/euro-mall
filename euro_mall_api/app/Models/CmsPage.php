<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CmsPage extends Model
{
    protected $fillable = [
        'slug',
        'title_en',
        'title_ar',
        'body_en',
        'body_ar',
    ];
}
