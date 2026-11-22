# AGENTS.md — Aturan Operasional AI Agent & Kontributor NusaSiaga

Dokumen ini mengatur aturan wajib yang **harus dipatuhi** oleh setiap AI agent maupun kontributor selama mengembangkan proyek **NusaSiaga**.

---

## 1. Konteks Proyek & Batasan Folder

- **Repositori**: `https://github.com/Aliff0305/NusaSiaga.git` (Root: `C:\NusaSiaga`, branch utama: `main`).
- **Pemisahan Monorepo Ketat**:
  - Semua kode API, migrasi, job sync BMKG/KLHK, dan dashboard/endpoint admin Laravel berada di dalam **`backend/`**.
  - Semua kode aplikasi mobile Flutter berada di dalam **`frontend/`**.
  - Semua PRD, DDL, kamus data, dan gambar ERD berada di dalam **`docs/`**.
  - **Dilarang** mencampur file Laravel ke dalam `frontend/` atau file Flutter ke dalam `backend/`.
- **Runtime Wajib**:
  - Gunakan **hanya** PHP di `C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe`.
  - Gunakan **hanya** MySQL di `C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe` (database `nusasiaga`).

---

## 2. ATURAN WAJIB GIT PUSH (RECORD & LAPORAN)

> [!CAUTION]
> **KEBIJAKAN WAJIB PROYEK:**
> Setiap kali menyelesaikan **fix bug**, **membuat fitur baru**, **memperbarui fitur**, **mengubah schema database**, atau **memperbarui dokumentasi/konfigurasi**, perubahan **WAJIB langsung di-commit dan di-`git push` ke remote `origin/main`** sebagai bahan **RECORD** dan **LAPORAN** resmi proyek.

### Checklist Wajib Sebelum Mengakhiri Tugas
1. **Verifikasi Teknis**:
   - Backend diubah → jalankan unit/feature test atau validasi syntax/migrasi.
   - Frontend diubah → jalankan `flutter analyze` dan `flutter test`.
   - Schema SQL diubah → verifikasi langsung di MySQL 8.4.3 Laragon.
2. **Pembaruan Dokumen Pelacakan**:
   - Perbarui status tugas di [`CHECKPOINT.md`](./CHECKPOINT.md).
   - Catat temuan teknis, keputusan arsitektur baru, atau perbaikan bug penting di [`MEMORY.md`](./MEMORY.md).
   - Catat rencana/entri commit di [`LASTGIT.md`](./LASTGIT.md) beserta hasil push aktual.
3. **Format Commit (Conventional Commits)**:
   - `feat(backend): ...` / `feat(frontend): ...` — Fitur baru
   - `fix(backend): ...` / `fix(frontend): ...` — Perbaikan bug
   - `docs: ...` / `docs(db): ...` — Perubahan PRD, schema, ERD, atau tata kelola
   - `refactor(...): ...` — Perbaikan struktur kode tanpa ubah perilaku
   - `test(...): ...` — Penambahan/pembaruan pengujian
   - `chore(...): ...` — Konfigurasi build, dependency, atau tooling
4. **Eksekusi Wajib Push**:
   ```powershell
   git -C C:\NusaSiaga status
   git -C C:\NusaSiaga add <file-terkait>
   git -C C:\NusaSiaga commit -m "<type>(<scope>): <ringkasan jelas>"
   git -C C:\NusaSiaga push origin main
   ```
   - Setelah push berhasil, catat hash commit singkat (`git rev-parse --short HEAD`) ke dalam [`LASTGIT.md`](./LASTGIT.md) lalu commit & push pembaruan `LASTGIT.md` tersebut (atau sertakan dalam catatan push berikutnya sesuai audit trail).
   - **Jangan pernah** melaporkan suatu tugas selesai apabila perubahan belum di-push ke `origin/main` (kecuali bila ada error jaringan/autentikasi yang harus dilaporkan apa adanya kepada pengguna).

---

## 3. Aturan Keamanan & Integritas Data

- **Dilarang** meng-commit file sensitif (`.env` berisi kredensial riil, kunci API NASA FIRMS pribadi, file `google-services.json` rahasia produksi, atau file keystore). Pastikan `.env.example` selalu tersedia sebagai template.
- **Jangan pernah** melewati validasi verifikasi petugas (`citizen_reports`) atau verifikasi admin (`donations` manual & `fund_disbursements`) dengan langsung menandai status `verified` pada input pengguna biasa (kecuali mode simulasi donasi yang eksplisit dikontrol oleh config server).
- Pertahankan keselarasan antara kode migrasi Laravel dengan [`docs/database/schema.sql`](./docs/database/schema.sql) dan [`docs/database/DATABASE_SCHEMA.md`](./docs/database/DATABASE_SCHEMA.md).
