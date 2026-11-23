<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class CitizenReport extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'reporter_id',
        'linked_disaster_event_id',
        'disaster_type',
        'report_category',
        'title',
        'description',
        'severity',
        'latitude',
        'longitude',
        'location_point',
        'address_text',
        'affected_people_estimate',
        'status',
        'verified_by',
        'verification_notes',
        'verified_at',
        'reported_at',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'float',
            'longitude' => 'float',
            'affected_people_estimate' => 'integer',
            'verified_at' => 'datetime',
            'reported_at' => 'datetime',
        ];
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function linkedDisasterEvent(): BelongsTo
    {
        return $this->belongsTo(DisasterEvent::class, 'linked_disaster_event_id');
    }

    public function media(): HasMany
    {
        return $this->hasMany(CitizenReportMedia::class)->orderBy('sort_order');
    }

    public function verificationLogs(): HasMany
    {
        return $this->hasMany(ReportVerificationLog::class)->orderByDesc('created_at');
    }
}
