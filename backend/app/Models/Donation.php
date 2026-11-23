<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Donation extends Model
{
    protected $fillable = [
        'campaign_id',
        'donor_id',
        'order_code',
        'donor_name',
        'donor_email',
        'is_anonymous',
        'amount',
        'payment_method',
        'payment_channel',
        'sender_bank_name',
        'sender_account_name',
        'payment_proof_url',
        'payment_proof_note',
        'payment_status',
        'verified_by',
        'verification_notes',
        'verified_at',
        'message',
        'paid_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'is_anonymous' => 'boolean',
            'amount' => 'float',
            'verified_at' => 'datetime',
            'paid_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function campaign(): BelongsTo
    {
        return $this->belongsTo(FundraisingCampaign::class, 'campaign_id');
    }

    public function donor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'donor_id');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
