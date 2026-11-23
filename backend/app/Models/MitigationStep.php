<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MitigationStep extends Model
{
    protected $fillable = [
        'mitigation_guide_id',
        'step_number',
        'title',
        'instruction',
        'is_critical_action',
        'illustration_url',
    ];

    protected function casts(): array
    {
        return [
            'step_number' => 'integer',
            'is_critical_action' => 'boolean',
        ];
    }

    public function guide(): BelongsTo
    {
        return $this->belongsTo(MitigationGuide::class, 'mitigation_guide_id');
    }
}
