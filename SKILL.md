# SKILL.md — Panduan Teknis & Standar Engineering NusaSiaga

Dokumen ini menjadi acuan teknis resmi bagi developer maupun AI agent dalam membangun, menguji, dan memelihara **NusaSiaga** (`C:\NusaSiaga`).

---

## 1. Environment & Binary Resmi (Laragon + Flutter)

Seluruh perintah CLI **wajib** menggunakan binary terverifikasi berikut agar versi runtime konsisten:

| Tool | Lokasi Binary Resmi | Versi Terverifikasi |
| :--- | :--- | :--- |
| **PHP** | `C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe` | PHP `8.3.33` (ZTS) |
| **Composer** | `C:\laragon\bin\composer\composer.bat` | Composer |
| **MySQL CLI** | `C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe` | MySQL `8.4.3` |
| **Flutter SDK** | `C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat` | Flutter `3.47.2` |
| **Dart SDK** | `C:\flutter_windows_3.47.2-stable\flutter\bin\dart.bat` | Dart (bundled) |

### Contoh Perintah PowerShell Baku

```powershell
# Cek versi PHP & ekstensi Laravel
& "C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" -v

# Jalankan Artisan di folder backend/
& "C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" C:\NusaSiaga\backend\artisan migrate --status

# Jalankan Composer dengan PHP 8.3.33 eksplisit
& "C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" C:\laragon\bin\composer\composer.phar --working-dir=C:\NusaSiaga\backend test

# Jalankan MySQL CLI
& "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root -D nusasiaga -e "SHOW TABLES;"

# Muat ulang schema.sql ke database nusasiaga
Get-Content -Raw -Encoding UTF8 C:\NusaSiaga\docs\database\schema.sql | & "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root --default-character-set=utf8mb4

# Perintah Flutter di folder frontend/
Push-Location C:\NusaSiaga\frontend
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" analyze
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" test
Pop-Location
```

---

## 2. Struktur Monorepo Terpisah

```text
C:\NusaSiaga\
├── backend/         # Hanya kode Laravel (REST API, Jobs, Scheduler, Tests)
├── frontend/        # Hanya kode Flutter (Mobile Android/iOS, Offline Cache, Widget Tests)
├── docs/            # PRD.md, schema.sql, DATABASE_SCHEMA.md, erd-nusasiaga.svg/png
├── SKILL.md         # Panduan engineering & tooling
├── AGENTS.md        # Aturan wajib agent & SOP wajib git push
├── MEMORY.md        # Memori teknis & keputusan desain permanen
├── CHECKPOINT.md    # Roadmap fase & progres pekerjaan
├── LASTGIT.md       # Log audit permanen setiap git push
└── README.md        # Dokumentasi gerbang proyek
```

---

## 3. Standar Arsitektur Backend (Laravel — PHP 8.3.33)

1. **Pola Layering**:
   - `Routes (`routes/api.php`)` → grup `/api/v1/...`, proteksi `auth:sanctum` & middleware role (`role:officer,admin`).
   - `FormRequest` → validasi input ketat (termasuk MIME & batas ukuran upload bukti laporan/donasi/penyaluran).
   - `Controller` → tipis; mendelegasikan logika bisnis ke `App\Services\*` atau `App\Actions\*`.
   - `Service` → wajib memakai `DB::transaction()` + `lockForUpdate()` saat mengubah nominal agregat (`collected_amount`, `disbursed_amount`, `donor_count`).
   - `ApiResource` → menyeragamkan format JSON (`{ success, message, data, meta }`).
2. **Integrasi Eksternal (BMKG & Kehutanan)**:
   - Gunakan adapter terpisah: `BmkgDisasterSyncService`, `KlhkSipongiSyncService`, dan `NasaFirmsFallbackService`.
   - Setiap eksekusi sync wajib mencatat baris audit di `external_sync_logs`.
   - Gunakan `updateOrCreate` berdasarkan kombinasi `(source, external_id)` untuk menjamin idempotensi.
3. **Standar Spasial MySQL 8.4 (`SRID 4326`)**:
   - Gunakan helper tunggal saat menulis kolom `location_point`:
     - `DB::raw("ST_SRID(POINT({$lng}, {$lat}), 4326)")` atau binding aman `ST_GeomFromText(?, 4326, 'axis-order=long-lat')`.
   - Jangan pernah membalik urutan argumen `(lat, lng)` di dalam `POINT(x, y)` karena MySQL 8.4 memvalidasi `[-90, 90]` untuk latitude.
4. **Keamanan & Integritas Dana**:
   - Pengajuan `fund_disbursements` wajib memvalidasi `SUM(items.subtotal) == amount` dan saldo tersisa mencukupi.
   - Hanya admin yang berhak mengubah `donations.payment_status` (manual transfer) dan `fund_disbursements.verification_status` ke `'verified'`.

---

## 4. Standar Arsitektur Frontend (Flutter 3.47.2)

1. **Struktur Feature-First**:
   - `lib/core/` (konfigurasi API `Dio`, interceptor Bearer Token via `flutter_secure_storage`, theme, spatial/currency formatters, local DB cache).
   - `lib/features/` (`auth`, `map`, `disasters`, `notifications`, `reports`, `fundraising`, `mitigation`, `officer_admin`).
2. **Offline-First untuk Catatan Mitigasi**:
   - Tabel `mitigation_guides`, `mitigation_steps`, dan `emergency_contacts` wajib di-cache secara lokal (`sqflite` / `hive`) saat sinkronisasi online agar langsung terbaca tanpa internet ketika terjadi bencana.
3. **Peta Terpadu**:
   - Gunakan marker clustering untuk titik panas kebakaran hutan dan pemisahan toggle layer: Gempa, Potensi Tsunami, Titik Panas Karhutla, Laporan Warga Terverifikasi.
4. **Transparansi Dana di UI**:
   - Tampilkan jelas 3 angka utama di detail kampanye: **Terkumpul**, **Disalurkan (Terverifikasi Admin)**, dan **Sisa Saldo**, serta lencana status verifikasi di setiap kartu penyaluran.

---

## 5. SOP Perubahan Schema & Verifikasi

1. Setiap perubahan skema database **wajib**:
   - Memperbarui migrasi Laravel di `backend/database/migrations/` dan menyinkronkannya ke `docs/database/schema.sql` serta `docs/database/DATABASE_SCHEMA.md`.
   - Menguji eksekusi langsung ke `C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe`.
   - Memperbarui gambar `docs/database/erd-nusasiaga.svg` dan `docs/database/erd-nusasiaga.png`.
2. Sebelum commit & push:
   - Jalankan test Laravel (`php artisan test`) / validasi PHP.
   - Jalankan `flutter analyze` & `flutter test` bila menyentuh `frontend/`.
   - Perbarui `CHECKPOINT.md` dan `LASTGIT.md`, lalu **wajib** `git commit` dan `git push origin main`.
