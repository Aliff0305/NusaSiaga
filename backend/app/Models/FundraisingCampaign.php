<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class FundraisingCampaign extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'creator_id',
        'disaster_event_id',
        'title',
        'slug',
        'summary',
        'story',
        'banner_image_url',
        'beneficiary_name',
        'beneficiary_location',
        'target_amount',
        'collected_amount',
        'disbursed_amount',
        'donor_count',
        'bank_name',
        'bank_account_number',
        'bank_account_holder',
        'qris_image_url',
        'supporting_document_url',
        'starts_at',
        'ends_at',
        'status',
        'approved_by',
        'approval_notes',
        'approved_at',
    ];

    protected function casts(): array
    {
        return [
            'target_amount' => 'float',
            'collected_amount' => 'float',
            'disbursed_amount' => 'float',
            'donor_count' => 'integer',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'approved_at' => 'datetime',
        ];
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creator_id');
    }

    public function disasterEvent(): BelongsTo
    {
        return $this->belongsTo(DisasterEvent::class);
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function donations(): HasMany
    {
        return $this->hasMany(Donation::class, 'campaign_id');
    }

    public function disbursements(): HasMany
    {
        return $this->hasMany(FundDisbursement::class, 'campaign_id');
    }

    public function updates(): HasMany
    {
        return $this->hasMany(CampaignUpdate::class, 'campaign_id')->orderByDesc('published_at');
    }
}
