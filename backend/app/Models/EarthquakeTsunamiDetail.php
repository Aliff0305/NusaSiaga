<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EarthquakeTsunamiDetail extends Model
{
    protected $fillable = [
        'disaster_event_id',
        'magnitude',
        'depth_km',
        'mmi_felt',
        'tsunami_potential',
        'tsunami_message',
        'shakemap_url',
        'bmkg_datetime_raw',
    ];

    protected function casts(): array
    {
        return [
            'magnitude' => 'float',
            'depth_km' => 'float',
        ];
    }

    public function disasterEvent(): BelongsTo
    {
        return $this->belongsTo(DisasterEvent::class);
    }
}
