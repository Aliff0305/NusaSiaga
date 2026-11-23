<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class DisasterEvent extends Model
{
    protected $fillable = [
        'external_id',
        'source',
        'disaster_type',
        'title',
        'description',
        'severity',
        'status',
        'latitude',
        'longitude',
        'location_point',
        'region_name',
        'province',
        'regency',
        'impact_radius_km',
        'occurred_at',
        'raw_payload',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'float',
            'longitude' => 'float',
            'impact_radius_km' => 'float',
            'occurred_at' => 'datetime',
            'raw_payload' => 'array',
        ];
    }

    public function earthquakeDetail(): HasOne
    {
        return $this->hasOne(EarthquakeTsunamiDetail::class);
    }

    public function hotspotDetail(): HasOne
    {
        return $this->hasOne(ForestFireHotspot::class);
    }

    public function citizenReports(): HasMany
    {
        return $this->hasMany(CitizenReport::class, 'linked_disaster_event_id');
    }

    public function campaigns(): HasMany
    {
        return $this->hasMany(FundraisingCampaign::class);
    }
}
