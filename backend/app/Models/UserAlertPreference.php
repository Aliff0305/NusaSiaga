<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserAlertPreference extends Model
{
    protected $fillable = [
        'user_id',
        'enable_earthquake',
        'min_earthquake_magnitude',
        'enable_tsunami',
        'enable_forest_fire',
        'min_hotspot_confidence',
        'enable_citizen_reports',
        'enable_fundraising_updates',
        'default_radius_km',
        'quiet_hours_start',
        'quiet_hours_end',
        'bypass_quiet_for_critical',
    ];

    protected function casts(): array
    {
        return [
            'enable_earthquake' => 'boolean',
            'min_earthquake_magnitude' => 'float',
            'enable_tsunami' => 'boolean',
            'enable_forest_fire' => 'boolean',
            'enable_citizen_reports' => 'boolean',
            'enable_fundraising_updates' => 'boolean',
            'default_radius_km' => 'integer',
            'bypass_quiet_for_critical' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
