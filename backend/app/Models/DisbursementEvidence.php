<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DisbursementEvidence extends Model
{
    public $timestamps = false;

    protected $table = 'disbursement_evidences';

    protected $fillable = [
        'disbursement_id',
        'evidence_type',
        'file_path',
        'file_url',
        'caption',
        'uploaded_at',
    ];

    protected function casts(): array
    {
        return [
            'uploaded_at' => 'datetime',
        ];
    }

    public function disbursement(): BelongsTo
    {
        return $this->belongsTo(FundDisbursement::class, 'disbursement_id');
    }
}
