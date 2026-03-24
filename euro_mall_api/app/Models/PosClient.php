<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PosClient extends Model
{
    protected $fillable = [
        'name',
        'oauth_client_id',
        'branch_code',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }
}
