<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'avatar_url',
        'kyc_status',
        'is_active',
        'email_verified_at',
        'last_latitude',
        'last_longitude',
        'last_location_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'last_location_at' => 'datetime',
            'last_latitude' => 'float',
            'last_longitude' => 'float',
            'is_active' => 'boolean',
            'password' => 'hashed',
        ];
    }

    public function kycSubmissions(): HasMany
    {
        return $this->hasMany(UserKycSubmission::class);
    }

    public function devices(): HasMany
    {
        return $this->hasMany(UserDevice::class);
    }

    public function monitoredLocations(): HasMany
    {
        return $this->hasMany(UserMonitoredLocation::class);
    }

    public function alertPreference(): HasOne
    {
        return $this->hasOne(UserAlertPreference::class);
    }

    public function alertNotifications(): HasMany
    {
        return $this->hasMany(AlertNotification::class);
    }

    public function citizenReports(): HasMany
    {
        return $this->hasMany(CitizenReport::class, 'reporter_id');
    }

    public function campaigns(): HasMany
    {
        return $this->hasMany(FundraisingCampaign::class, 'creator_id');
    }

    public function donations(): HasMany
    {
        return $this->hasMany(Donation::class, 'donor_id');
    }
}
