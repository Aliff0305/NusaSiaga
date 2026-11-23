<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExternalSyncLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'provider',
        'endpoint_url',
        'http_status',
        'status',
        'records_fetched',
        'records_inserted',
        'records_updated',
        'duration_ms',
        'error_message',
        'synced_at',
    ];

    protected function casts(): array
    {
        return [
            'synced_at' => 'datetime',
        ];
    }
}
