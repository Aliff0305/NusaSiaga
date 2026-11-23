<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AlertNotification extends Model
{
    protected $fillable = [
        'user_id',
        'disaster_event_id',
        'monitored_location_id',
        'category',
        'priority',
        'title',
        'body',
        'distance_km',
        'payload_json',
        'delivery_status',
        'fcm_message_id',
        'sent_at',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'distance_km' => 'float',
            'payload_json' => 'array',
            'sent_at' => 'datetime',
            'read_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function disasterEvent(): BelongsTo
    {
        return $this->belongsTo(DisasterEvent::class);
    }

    public function monitoredLocation(): BelongsTo
    {
        return $this->belongsTo(UserMonitoredLocation::class);
    }
}
