<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ForestFireHotspot extends Model
{
    protected $fillable = [
        'disaster_event_id',
        'satellite',
        'confidence_level',
        'confidence_score',
        'brightness_kelvin',
        'frp_mw',
        'land_cover_type',
        'forest_area_status',
        'district',
        'acquired_at',
    ];

    protected function casts(): array
    {
        return [
            'confidence_score' => 'integer',
            'brightness_kelvin' => 'float',
            'frp_mw' => 'float',
            'acquired_at' => 'datetime',
        ];
    }

    public function disasterEvent(): BelongsTo
    {
        return $this->belongsTo(DisasterEvent::class);
    }
}
