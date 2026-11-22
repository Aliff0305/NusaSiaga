# MEMORY.md — Memori Teknis & Keputusan Proyek NusaSiaga

Dokumen ini menyimpan konteks teknis permanen, keputusan desain yang disepakati pengguna, dan temuan penting selama pengembangan **NusaSiaga**.

---

## 1. Informasi Lingkungan & Path Terverifikasi

| Komponen | Path / Konfigurasi Aktual | Catatan |
| :--- | :--- | :--- |
| **Root Repositori** | `C:\NusaSiaga` | Branch `main`, remote `origin` → `https://github.com/Aliff0305/NusaSiaga.git` |
| **PHP CLI** | `C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe` | PHP `8.3.33` (ZTS) |
| **Composer** | `C:\laragon\bin\composer\composer.bat` | Terpasang di Laragon |
| **MySQL Server & CLI** | `C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe` | MySQL `8.4.3`, host `127.0.0.1:3306`, user dev `root` (tanpa password) |
| **Database Aktif** | `nusasiaga` (`utf8mb4_unicode_ci`, `InnoDB`) | Sudah memuat **24 tabel**, **35 FK**, dan **3 Spatial Index** |
| **Flutter SDK** | `C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat` | Flutter `3.47.2` |
| **Renderer ERD** | `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe` | Digunakan dalam mode `--headless=new` untuk render `erd-nusasiaga.svg` → `erd-nusasiaga.png` |

---

## 2. Keputusan Arsitektur yang Disepakati Pengguna (22 Nov 2026)

1. **Cakupan Fase 1 (Opsi A)**:
   - Fase 1 berfokus pada PRD lengkap (`docs/PRD.md`), skema database MySQL 8.4 terverifikasi (`docs/database/schema.sql`, `DATABASE_SCHEMA.md`, `erd-nusasiaga.svg/png`), dokumen tata kelola (`SKILL.md`, `AGENTS.md`, `MEMORY.md`, `CHECKPOINT.md`, `LASTGIT.md`), dan pemisahan awal folder `backend/` & `frontend/`.
   - Scaffold penuh Laravel (`composer create-project`) dan Flutter (`flutter create`) masuk **Fase 2**.
2. **Integrasi Data Titik Panas Kehutanan**:
   - **Sumber Primer**: **KLHK SiPongi** (Kementerian Kehutanan).
   - **Fallback / Enrichment**: **NASA FIRMS** (VIIRS/MODIS *bounding box* Indonesia) otomatis aktif bila endpoint KLHK SiPongi gagal atau butuh data tambahan (`brightness_kelvin`, `frp_mw`).
3. **Metode Pembayaran Donasi (v1)**:
   - Tidak menggunakan payment gateway pihak ketiga (Midtrans/Xendit) pada rilis awal.
   - Menggunakan **Transfer Manual (`manual_transfer`)** dengan unggah bukti bayar oleh donatur dan verifikasi admin, serta **Mode Simulasi (`simulation`)** untuk kebutuhan pengujian dan demo akademik.
4. **Kewajiban Git Push**:
   - Setiap *fix bug*, pembuatan fitur baru, pembaruan fitur, atau pembaruan skema/dokumentasi **wajib** langsung di-commit dan di-`git push` ke `origin/main`, serta dicatat di `LASTGIT.md` sebagai bahan record dan laporan.

---

## 3. Temuan Teknis Penting (Pitfalls & Solusi)

1. **MySQL 8.4.3 Spatial `SRID 4326` Axis-Order (Teruji Langsung)**:
   - Di MySQL 8.4.3, `ST_GeomFromText('POINT(-6.2088 106.8456)', 4326)` menggunakan urutan **(latitude, longitude)**, sedangkan constructor biner `POINT(x, y)` menerima **(longitude, latitude)** sehingga pemanggilan yang benar adalah `ST_SRID(POINT(106.8456, -6.2088), 4326)` atau WKT dengan opsi `'axis-order=long-lat'`.
   - Memasukkan `(lat, lng)` ke `POINT(...)` lalu dibungkus `ST_SRID(..., 4326)` memicu **ERROR 3732: latitude out of range [-90, 90]** pada bujur Indonesia (`95..141`).
2. **Spatial Index Constraint**:
   - Kolom bertipe `POINT` yang diindeks `SPATIAL KEY` di MySQL 8.4 wajib bertipe `NOT NULL` dan memiliki `SRID 4326` eksplisit agar query spasial tidak diabaikan oleh optimizer.
3. **Headless Edge Rendering di Windows**:
   - Edge headless modern memerlukan flag `--headless=new --disable-gpu --no-sandbox` agar screenshot PNG berukuran besar (`3600x2540`) tersimpan dengan andal.
