<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmergencyContact extends Model
{
    protected $fillable = [
        'name',
        'agency',
        'phone_number',
        'disaster_scope',
        'province',
        'description',
        'is_national',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_national' => 'boolean',
            'sort_order' => 'integer',
            'is_active' => 'boolean',
        ];
    }
}
