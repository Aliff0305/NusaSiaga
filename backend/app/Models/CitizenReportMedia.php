<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CitizenReportMedia extends Model
{
    public $timestamps = false;

    protected $table = 'citizen_report_media';

    protected $fillable = [
        'citizen_report_id',
        'media_type',
        'file_path',
        'file_url',
        'mime_type',
        'file_size_bytes',
        'caption',
        'sort_order',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'file_size_bytes' => 'integer',
            'sort_order' => 'integer',
            'created_at' => 'datetime',
        ];
    }

    public function citizenReport(): BelongsTo
    {
        return $this->belongsTo(CitizenReport::class);
    }
}
