<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserMitigationChecklist extends Model
{
    public const CREATED_AT = null;

    protected $fillable = [
        'user_id',
        'mitigation_step_id',
        'is_completed',
        'completed_at',
        'personal_note',
    ];

    protected function casts(): array
    {
        return [
            'is_completed' => 'boolean',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function step(): BelongsTo
    {
        return $this->belongsTo(MitigationStep::class, 'mitigation_step_id');
    }
}
