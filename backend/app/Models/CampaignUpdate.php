<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CampaignUpdate extends Model
{
    protected $fillable = [
        'campaign_id',
        'author_id',
        'disbursement_id',
        'title',
        'content',
        'image_url',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'published_at' => 'datetime',
        ];
    }

    public function campaign(): BelongsTo
    {
        return $this->belongsTo(FundraisingCampaign::class, 'campaign_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function disbursement(): BelongsTo
    {
        return $this->belongsTo(FundDisbursement::class, 'disbursement_id');
    }
}
