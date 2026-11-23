<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MitigationGuide extends Model
{
    protected $fillable = [
        'disaster_type',
        'phase',
        'title',
        'slug',
        'summary',
        'content',
        'icon_name',
        'priority_order',
        'source_reference',
        'is_published',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'priority_order' => 'integer',
            'is_published' => 'boolean',
        ];
    }

    public function steps(): HasMany
    {
        return $this->hasMany(MitigationStep::class)->orderBy('step_number');
    }
}
