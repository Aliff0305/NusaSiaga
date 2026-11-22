# CHECKPOINT.md — Roadmap & Pelacakan Progres NusaSiaga

> Terakhir diperbarui: **22 November 2026** • Fase Saat Ini: **Fase 1 Selesai — Siap Masuk Fase 2**

---

## Ringkasan Progres Keseluruhan

| Fase | Nama Fase | Status | Progres |
| :---: | :--- | :---: | :---: |
| **Fase 1** | PRD, Schema Database + ERD, Tata Kelola & Struktur Monorepo | ✅ Selesai | 100% |
| **Fase 2** | Scaffold Laravel (`backend/`), Migrasi & Seeder, Scaffold Flutter (`frontend/`), Auth & RBAC | ⏳ Berikutnya | 0% |
| **Fase 3** | Integrasi Real-Time BMKG & KLHK SiPongi/FIRMS + Peta Terpadu | ⬜ Belum Mulai | 0% |
| **Fase 4** | Notifikasi Berbasis Lokasi (`SRID 4326`) & Integrasi FCM | ⬜ Belum Mulai | 0% |
| **Fase 5** | Laporan Warga & Panel Verifikasi Petugas | ⬜ Belum Mulai | 0% |
| **Fase 6** | Penggalangan Dana, Donasi Manual/Simulasi & Laporan Penyaluran Terverifikasi Admin | ⬜ Belum Mulai | 0% |
| **Fase 7** | Catatan Mitigasi Offline-First, Kontak Darurat, Pengujian Menyeluruh & Finalisasi | ⬜ Belum Mulai | 0% |

---

## Detail Checklist per Fase

### ✅ Fase 1 — Perencanaan, PRD, Schema Database & Tata Kelola (Selesai)
- [x] Verifikasi workspace Git (`origin/main`), PHP 8.3.33, Composer, MySQL 8.4.3, dan Flutter 3.47.2.
- [x] Rancangan lengkap **24 tabel dalam 6 domain** di [`docs/database/schema.sql`](./docs/database/schema.sql).
- [x] Eksekusi & verifikasi `schema.sql` langsung ke MySQL 8.4.3 Laragon (`nusasiaga`: 24 tabel, 35 FK, 3 Spatial Index).
- [x] Pembuatan & inspeksi visual gambar ERD resolusi tinggi: [`erd-nusasiaga.svg`](./docs/database/erd-nusasiaga.svg) dan [`erd-nusasiaga.png`](./docs/database/erd-nusasiaga.png).
- [x] Penyusunan kamus data & query terverifikasi di [`docs/database/DATABASE_SCHEMA.md`](./docs/database/DATABASE_SCHEMA.md).
- [x] Penyusunan PRD lengkap NusaSiaga di [`docs/PRD.md`](./docs/PRD.md).
- [x] Pembuatan dokumen tata kelola: [`SKILL.md`](./SKILL.md), [`AGENTS.md`](./AGENTS.md), [`MEMORY.md`](./MEMORY.md), [`CHECKPOINT.md`](./CHECKPOINT.md), [`LASTGIT.md`](./LASTGIT.md).
- [x] Pemisahan awal folder [`backend/`](./backend/README.md) dan [`frontend/`](./frontend/README.md) serta pembaruan [`README.md`](./README.md).
- [x] Commit dan `git push origin main` + pencatatan log di `LASTGIT.md`.

### ⏳ Fase 2 — Inisialisasi Proyek Backend & Frontend (Rencana Berikutnya)
- [ ] Scaffold project Laravel di `backend/` menggunakan PHP 8.3.33 & Composer, lalu sambungkan ke database MySQL `nusasiaga`.
- [ ] Buat Laravel Migrations, Models (24 entitas + relasi Eloquent), Policies RBAC (`citizen`, `campaign_creator`, `officer`, `admin`), dan Laravel Sanctum auth API.
- [ ] Buat Seeder awal untuk akun demo tiap role, `mitigation_guides`, `mitigation_steps`, dan `emergency_contacts`.
- [ ] Scaffold project Flutter di `frontend/` (`flutter create`), konfigurasi struktur Feature-First, `Dio` HTTP client, dan `flutter_secure_storage`.
- [ ] Implementasi layar Splash, Login, Register, dan Profil dasar di Flutter.
- [ ] Commit & `git push origin main` + update `LASTGIT.md`.

### ⬜ Fase 3 — Integrasi BMKG, Kehutanan & Peta Terpadu
- [ ] Implementasi `BmkgDisasterSyncService` (Autogempa, Gempa Terkini, Gempa Dirasakan, InaTEWS Tsunami).
- [ ] Implementasi `KlhkSipongiSyncService` + `NasaFirmsFallbackService` + pencatatan `external_sync_logs`.
- [ ] Konfigurasi Laravel Scheduler & endpoint `GET /api/v1/map/overview` dan `GET /api/v1/disasters`.
- [ ] Implementasi Peta Terpadu multi-layer + marker clustering + filter di Flutter.

### ⬜ Fase 4 — Notifikasi Berbasis Lokasi
- [ ] Implementasi CRUD `user_monitored_locations` & `user_alert_preferences`.
- [ ] Implementasi Geo-Alert Engine (`ST_Distance_Sphere`), evaluasi quiet hours + critical bypass, dan Laravel Queue FCM.
- [ ] Implementasi UI manajemen lokasi pantauan & inbox notifikasi di Flutter.

### ⬜ Fase 5 — Laporan Warga & Verifikasi Petugas
- [ ] Implementasi endpoint laporan warga + multi-upload foto/video (`citizen_reports`, `citizen_report_media`).
- [ ] Implementasi workflow verifikasi petugas (`officer`/`admin`), `report_verification_logs`, dan promosi laporan verified ke peta.
- [ ] Implementasi UI form lapor warga & panel verifikasi petugas di Flutter.

### ⬜ Fase 6 — Penggalangan Dana & Transparansi Penyaluran
- [ ] Implementasi pengajuan & review KYC (`user_kyc_submissions`).
- [ ] Implementasi CRUD & approval kampanye (`fundraising_campaigns`).
- [ ] Implementasi donasi `manual_transfer` (+ unggah bukti bayar & verifikasi admin) serta mode `simulation`.
- [ ] Implementasi pengajuan `fund_disbursements` (`disbursement_items` + `disbursement_evidences`) dan verifikasi transparansi oleh admin.
- [ ] Implementasi UI daftar kampanye, pelacakan progres, tab penyaluran terverifikasi admin, dan modul verifikasi admin di Flutter.

### ⬜ Fase 7 — Catatan Mitigasi Offline-First & Pengujian Akhir
- [ ] Implementasi cache lokal Flutter (`sqflite`/`hive`) untuk `mitigation_guides`, `mitigation_steps`, dan `emergency_contacts`.
- [ ] Implementasi checklist kesiapsiagaan (`user_mitigation_checklists`) dan tombol cepat hotline darurat.
- [ ] Menjalankan suite pengujian otomatis Laravel & Flutter serta verifikasi end-to-end.
