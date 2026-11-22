# NusaSiaga Frontend (Flutter Mobile App)

Folder ini dikhususkan untuk seluruh kode aplikasi mobile **NusaSiaga** berbasis **Flutter (`3.47.2`)** untuk Android & iOS.

> **Status Saat Ini (Fase 1)**: Struktur folder `frontend/` telah dipisahkan dari `backend/`. Inisialisasi project Flutter (`flutter create`) dan implementasi UI dijadwalkan pada **Fase 2** (lihat [`../CHECKPOINT.md`](../CHECKPOINT.md)).

---

## Prasyarat SDK Lokal

- **Flutter**: `C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat` (versi `3.47.2`)
- **Dart**: bundled bersama Flutter SDK

---

## Arsitektur Feature-First Target (`lib/`)

```text
frontend/
├── lib/
│   ├── app/                    # Konfigurasi tema, router, bottom navigation shell
│   ├── core/
│   │   ├── config/             # Base URL API, env flags
│   │   ├── network/            # Dio client, Auth interceptor, error mapping
│   │   ├── storage/            # FlutterSecureStorage (token), Hive/SQLite (cache offline mitigasi)
│   │   ├── location/           # Geolocator service & permission handler
│   │   └── widgets/            # Komponen UI reusable (badge severity, rupiah formatter, kartu verifikasi)
│   └── features/
│       ├── auth/               # Login, Register, Profil, pengajuan KYC penggagas
│       ├── map/                # Peta Terpadu multi-layer (Gempa, Tsunami, Hotspot KLHK, Laporan Verified)
│       ├── disasters/          # Detail gempa + Shakemap, detail tsunami, detail hotspot karhutla
│       ├── notifications/      # Lokasi pantauan, preferensi alert, kotak masuk alert berbasis jarak
│       ├── reports/            # Form laporan warga + upload foto/video, feed laporan terverifikasi
│       ├── fundraising/        # Daftar & detail kampanye, donasi (Transfer Manual + bukti / Simulasi), progres & penyaluran
│       ├── mitigation/         # Catatan mitigasi (Pra/Saat/Pasca) offline-first, checklist pribadi, kontak darurat
│       └── officer_admin/      # Panel mobile verifikasi laporan (Petugas) & verifikasi donasi/penyaluran (Admin)
└── test/                       # Unit & Widget Tests
```

---

## Panduan Inisialisasi Fase 2

```powershell
# 1. Buat project Flutter di C:\NusaSiaga\frontend
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" create --org id.nusasiaga --project-name nusasiaga C:\NusaSiaga\frontend

# 2. Cek analisa statis & pengujian
Push-Location C:\NusaSiaga\frontend
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" pub get
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" analyze
& "C:\flutter_windows_3.47.2-stable\flutter\bin\flutter.bat" test
Pop-Location
```

Referensi lengkap:
- [`../docs/PRD.md`](../docs/PRD.md)
- [`../SKILL.md`](../SKILL.md)
