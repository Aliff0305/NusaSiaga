# NusaSiaga Backend (Laravel REST API)

Folder ini dikhususkan untuk seluruh kode backend **NusaSiaga** berbasis **Laravel** menggunakan **PHP 8.3.33** dan database **MySQL 8.4.3** (`nusasiaga`).

> **Status Saat Ini (Fase 1)**: Struktur folder `backend/` telah dipisahkan dari `frontend/`. Inisialisasi project Laravel (`composer create-project`) dan implementasi modul dijadwalkan pada **Fase 2** (lihat [`../CHECKPOINT.md`](../CHECKPOINT.md)).

---

## Prasyarat Binary Lokal (Laragon)

| Komponen | Lokasi Binary |
| :--- | :--- |
| PHP 8.3.33 | `C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe` |
| Composer | `C:\laragon\bin\composer\composer.bat` |
| MySQL 8.4.3 | `C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe` |

---

## Arsitektur Modul Target (`app/`)

```text
backend/
├── app/
│   ├── Console/Commands/       # SyncBmkgDisastersCommand, SyncForestHotspotsCommand
│   ├── Http/
│   │   ├── Controllers/Api/V1/ # Auth, Map, Disaster, Location, Report, Campaign, Donation, Disbursement, Mitigation, Admin
│   │   ├── Middleware/         # EnsureUserHasRole (RBAC: citizen, campaign_creator, officer, admin)
│   │   ├── Requests/           # FormRequest validasi ketat & upload media/bukti
│   │   └── Resources/          # API Resource terstandar
│   ├── Jobs/                   # EvaluateLocationAlertsJob, DispatchFcmAlertJob
│   ├── Models/                 # 24 Eloquent models selaras dengan docs/database/schema.sql
│   ├── Policies/               # Otorisasi per role & kepemilikan data
│   └── Services/
│       ├── Integrations/       # BmkgDisasterSyncService, KlhkSipongiSyncService, NasaFirmsFallbackService
│       ├── Geo/                # SpatialQueryService (SRID 4326) & AlertMatcherService
│       ├── Reports/            # CitizenReportVerificationService
│       └── Fundraising/        # CampaignService, DonationVerificationService, DisbursementService
├── database/
│   ├── migrations/             # Sinkron dengan docs/database/schema.sql
│   └── seeders/                # Demo users, mitigation_guides, mitigation_steps, emergency_contacts
├── routes/
│   ├── api.php                 # Endpoint /api/v1/* (Laravel Sanctum)
│   └── console.php             # Jadwal sync BMKG (1-5 menit) & KLHK/FIRMS (15-30 menit)
└── tests/                      # PHPUnit / Pest Feature & Unit Tests
```

---

## Panduan Inisialisasi Fase 2

```powershell
# 1. Scaffold Laravel di C:\NusaSiaga\backend menggunakan PHP 8.3.33 Laragon
& "C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" C:\laragon\bin\composer\composer.phar create-project laravel/laravel C:\NusaSiaga\backend

# 2. Konfigurasi .env mengarah ke MySQL 8.4.3 Laragon
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=nusasiaga
# DB_USERNAME=root
# DB_PASSWORD=

# 3. Verifikasi koneksi & jalankan server dev
& "C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" C:\NusaSiaga\backend\artisan serve
```

Referensi lengkap:
- [`../docs/PRD.md`](../docs/PRD.md)
- [`../docs/database/DATABASE_SCHEMA.md`](../docs/database/DATABASE_SCHEMA.md)
- [`../SKILL.md`](../SKILL.md)
