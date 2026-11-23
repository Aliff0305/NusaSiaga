<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DisbursementItem extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'disbursement_id',
        'item_name',
        'category',
        'quantity',
        'unit',
        'unit_price',
        'subtotal',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'float',
            'unit_price' => 'float',
            'subtotal' => 'float',
            'created_at' => 'datetime',
        ];
    }

    public function disbursement(): BelongsTo
    {
        return $this->belongsTo(FundDisbursement::class, 'disbursement_id');
    }
}
