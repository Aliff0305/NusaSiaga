<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class FundDisbursement extends Model
{
    protected $fillable = [
        'campaign_id',
        'submitted_by',
        'disbursement_code',
        'title',
        'description',
        'amount',
        'disbursement_date',
        'recipient_group',
        'recipient_location',
        'beneficiary_count',
        'verification_status',
        'verified_by',
        'verification_notes',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'float',
            'disbursement_date' => 'date',
            'beneficiary_count' => 'integer',
            'verified_at' => 'datetime',
        ];
    }

    public function campaign(): BelongsTo
    {
        return $this->belongsTo(FundraisingCampaign::class, 'campaign_id');
    }

    public function submitter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'submitted_by');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function items(): HasMany
    {
        return $this->hasMany(DisbursementItem::class, 'disbursement_id');
    }

    public function evidences(): HasMany
    {
        return $this->hasMany(DisbursementEvidence::class, 'disbursement_id');
    }
}
