-- ============================================================================
-- NusaSiaga Database Schema (MySQL 8.4.3 / InnoDB / utf8mb4_unicode_ci)
-- ============================================================================
-- Platform terpadu informasi gempa bumi & potensi tsunami (BMKG), titik panas
-- kebakaran hutan (KLHK SiPongi + NASA FIRMS fallback), peta terpadu,
-- notifikasi berbasis lokasi (Spatial SRID 4326), laporan warga terverifikasi
-- petugas, penggalangan dana & laporan penyaluran terverifikasi admin, serta
-- catatan mitigasi bencana & kontak darurat.
--
-- Total: 24 Tabel dalam 6 Domain
-- Catatan Spatial SRID 4326:
--   MySQL 8.0+ SRID 4326 mengikuti axis-order EPSG (latitude, longitude).
--   Gunakan ST_SRID(POINT(longitude, latitude), 4326) dengan hati-hati atau
--   ST_GeomFromText(CONCAT('POINT(', latitude, ' ', longitude, ')'), 4326)
--   atau ST_PointFromText(..., 4326, 'axis-order=long-lat') secara konsisten.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `nusasiaga`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `nusasiaga`;

SET NAMES utf8mb4;
SET TIME_ZONE = '+07:00';

-- ============================================================================
-- DOMAIN 1: IDENTITAS, AUTENTIKASI & RBAC (4 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL COMMENT 'Nama lengkap pengguna / lembaga',
  `email` VARCHAR(191) NOT NULL COMMENT 'Email unik login',
  `phone` VARCHAR(30) NULL DEFAULT NULL COMMENT 'Nomor WhatsApp / telepon aktif',
  `password` VARCHAR(255) NOT NULL COMMENT 'Hash bcrypt/argon2 password Laravel',
  `role` ENUM('citizen', 'campaign_creator', 'officer', 'admin') NOT NULL DEFAULT 'citizen' COMMENT 'Hak akses RBAC utama',
  `avatar_url` VARCHAR(255) NULL DEFAULT NULL,
  `kyc_status` ENUM('unverified', 'pending', 'verified', 'rejected') NOT NULL DEFAULT 'unverified' COMMENT 'Status verifikasi KYC penggagas kampanye',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
  `last_latitude` DECIMAL(10,7) NULL DEFAULT NULL,
  `last_longitude` DECIMAL(10,7) NULL DEFAULT NULL,
  `last_location_at` TIMESTAMP NULL DEFAULT NULL,
  `remember_token` VARCHAR(100) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_phone` (`phone`),
  KEY `idx_users_role_active` (`role`, `is_active`),
  KEY `idx_users_kyc_status` (`kyc_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Akun pengguna NusaSiaga dengan peran RBAC dan status KYC';

CREATE TABLE IF NOT EXISTS `user_kyc_submissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `identity_type` ENUM('ktp', 'organization_sk') NOT NULL COMMENT 'Jenis dokumen identitas penggagas',
  `identity_number` VARCHAR(64) NOT NULL COMMENT 'NIK / Nomor SK Organisasi',
  `organization_name` VARCHAR(180) NULL DEFAULT NULL,
  `id_card_photo_url` VARCHAR(255) NOT NULL,
  `selfie_photo_url` VARCHAR(255) NOT NULL,
  `status` ENUM('pending', 'verified', 'rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `review_notes` TEXT NULL,
  `reviewed_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_kyc_user_status` (`user_id`, `status`),
  KEY `idx_kyc_status_created` (`status`, `created_at`),
  CONSTRAINT `fk_kyc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kyc_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Pengajuan verifikasi KYC penggagas kampanye oleh admin';

CREATE TABLE IF NOT EXISTS `user_devices` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `fcm_token` VARCHAR(255) NOT NULL COMMENT 'Token Firebase Cloud Messaging unik per instalasi',
  `platform` ENUM('android', 'ios', 'web') NOT NULL,
  `device_name` VARCHAR(120) NULL DEFAULT NULL,
  `app_version` VARCHAR(30) NULL DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `last_active_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_devices_fcm` (`fcm_token`),
  KEY `idx_user_devices_user_active` (`user_id`, `is_active`),
  CONSTRAINT `fk_user_devices_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Registrasi token FCM perangkat pengguna untuk push notification';

CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` VARCHAR(255) NOT NULL,
  `tokenable_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `token` VARCHAR(64) NOT NULL,
  `abilities` TEXT NULL,
  `last_used_at` TIMESTAMP NULL DEFAULT NULL,
  `expires_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pat_token` (`token`),
  KEY `idx_pat_tokenable` (`tokenable_type`, `tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabel token autentikasi API Laravel Sanctum';

-- ============================================================================
-- DOMAIN 2: DATA BENCANA & INTEGRASI BMKG / KEHUTANAN (4 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `disaster_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `external_id` VARCHAR(120) NULL DEFAULT NULL COMMENT 'ID unik dari sumber eksternal untuk deduplikasi',
  `source` ENUM('bmkg_earthquake', 'bmkg_tsunami', 'klhk_sipongi', 'nasa_firms', 'citizen_verified', 'manual_admin') NOT NULL,
  `disaster_type` ENUM('earthquake', 'tsunami', 'forest_fire') NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `severity` ENUM('info', 'low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
  `status` ENUM('active', 'monitoring', 'resolved', 'cancelled') NOT NULL DEFAULT 'active',
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `location_point` POINT NOT NULL SRID 4326 COMMENT 'Koordinat spasial WGS84 untuk filter jarak/radius',
  `region_name` VARCHAR(180) NULL DEFAULT NULL,
  `province` VARCHAR(120) NULL DEFAULT NULL,
  `regency` VARCHAR(120) NULL DEFAULT NULL,
  `impact_radius_km` DECIMAL(6,2) NOT NULL DEFAULT 50.00,
  `occurred_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `raw_payload` JSON NULL COMMENT 'Snapshot payload asli BMKG / KLHK SiPongi / NASA FIRMS',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_disaster_source_ext` (`source`, `external_id`),
  SPATIAL KEY `sidx_disaster_events_location` (`location_point`),
  KEY `idx_disaster_type_occurred` (`disaster_type`, `occurred_at`),
  KEY `idx_disaster_status_severity` (`status`, `severity`),
  KEY `idx_disaster_province` (`province`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabel induk terpadu kejadian gempa, potensi tsunami, dan titik panas karhutla';

CREATE TABLE IF NOT EXISTS `earthquake_tsunami_details` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `disaster_event_id` BIGINT UNSIGNED NOT NULL,
  `magnitude` DECIMAL(4,2) NOT NULL COMMENT 'Magnitudo gempa (M)',
  `depth_km` DECIMAL(6,2) NOT NULL COMMENT 'Kedalaman hiposentrum (km)',
  `mmi_felt` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Wilayah & skala MMI yang dirasakan',
  `tsunami_potential` ENUM('none', 'waspada', 'siaga', 'awas') NOT NULL DEFAULT 'none',
  `tsunami_message` TEXT NULL,
  `shakemap_url` VARCHAR(255) NULL DEFAULT NULL COMMENT 'URL gambar Shakemap BMKG',
  `bmkg_datetime_raw` VARCHAR(64) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_eq_detail_event` (`disaster_event_id`),
  KEY `idx_eq_magnitude` (`magnitude`),
  KEY `idx_eq_tsunami_potential` (`tsunami_potential`),
  CONSTRAINT `fk_eq_detail_event` FOREIGN KEY (`disaster_event_id`) REFERENCES `disaster_events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Atribut seismik gempa bumi dan status peringatan dini tsunami BMKG';

CREATE TABLE IF NOT EXISTS `forest_fire_hotspots` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `disaster_event_id` BIGINT UNSIGNED NOT NULL,
  `satellite` VARCHAR(50) NULL DEFAULT NULL COMMENT 'Contoh: NOAA-20, SNPP, Terra, Aqua',
  `confidence_level` ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
  `confidence_score` TINYINT UNSIGNED NULL DEFAULT NULL COMMENT 'Skor kepercayaan 0-100',
  `brightness_kelvin` DECIMAL(6,2) NULL DEFAULT NULL,
  `frp_mw` DECIMAL(8,2) NULL DEFAULT NULL COMMENT 'Fire Radiative Power (Megawatt)',
  `land_cover_type` VARCHAR(100) NULL DEFAULT NULL,
  `forest_area_status` VARCHAR(100) NULL DEFAULT NULL COMMENT 'Hutan Lindung / Konservasi / APL / Gambut',
  `district` VARCHAR(100) NULL DEFAULT NULL COMMENT 'Kecamatan lokasi titik panas',
  `acquired_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hotspot_detail_event` (`disaster_event_id`),
  KEY `idx_hotspot_confidence_acquired` (`confidence_level`, `acquired_at`),
  CONSTRAINT `fk_hotspot_detail_event` FOREIGN KEY (`disaster_event_id`) REFERENCES `disaster_events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Atribut titik panas karhutla dari KLHK SiPongi dan fallback NASA FIRMS';

CREATE TABLE IF NOT EXISTS `external_sync_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `provider` ENUM('bmkg_autogempa', 'bmkg_gempaterkini', 'bmkg_gempadirasakan', 'klhk_sipongi', 'nasa_firms') NOT NULL,
  `endpoint_url` VARCHAR(255) NOT NULL,
  `http_status` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `status` ENUM('success', 'partial', 'failed') NOT NULL,
  `records_fetched` INT UNSIGNED NOT NULL DEFAULT 0,
  `records_inserted` INT UNSIGNED NOT NULL DEFAULT 0,
  `records_updated` INT UNSIGNED NOT NULL DEFAULT 0,
  `duration_ms` INT UNSIGNED NULL DEFAULT NULL,
  `error_message` TEXT NULL,
  `synced_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sync_provider_time` (`provider`, `synced_at`),
  KEY `idx_sync_status` (`status`, `synced_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Log audit sinkronisasi terjadwal API BMKG dan Kehutanan (KLHK/FIRMS)';

-- ============================================================================
-- DOMAIN 3: NOTIFIKASI BERBASIS LOKASI (3 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `user_monitored_locations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `label` VARCHAR(80) NOT NULL COMMENT 'Label lokasi: Rumah, Orang Tua, Kantor, dll',
  `address` VARCHAR(255) NULL DEFAULT NULL,
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `location_point` POINT NOT NULL SRID 4326,
  `radius_km` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  SPATIAL KEY `sidx_monitored_locations_point` (`location_point`),
  KEY `idx_monitored_user_active` (`user_id`, `is_active`),
  CONSTRAINT `fk_monitored_loc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Daftar lokasi pantauan tersimpan milik pengguna beserta radius alert';

CREATE TABLE IF NOT EXISTS `user_alert_preferences` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `enable_earthquake` TINYINT(1) NOT NULL DEFAULT 1,
  `min_earthquake_magnitude` DECIMAL(3,1) NOT NULL DEFAULT 4.5,
  `enable_tsunami` TINYINT(1) NOT NULL DEFAULT 1,
  `enable_forest_fire` TINYINT(1) NOT NULL DEFAULT 1,
  `min_hotspot_confidence` ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
  `enable_citizen_reports` TINYINT(1) NOT NULL DEFAULT 1,
  `enable_fundraising_updates` TINYINT(1) NOT NULL DEFAULT 1,
  `default_radius_km` SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `quiet_hours_start` TIME NULL DEFAULT NULL,
  `quiet_hours_end` TIME NULL DEFAULT NULL,
  `bypass_quiet_for_critical` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Tetap bunyikan alert kritis/tsunami saat quiet hours',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_alert_pref_user` (`user_id`),
  CONSTRAINT `fk_alert_pref_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Preferensi ambang batas, jenis bencana, dan quiet hours notifikasi pengguna';

CREATE TABLE IF NOT EXISTS `alert_notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `disaster_event_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `monitored_location_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `category` ENUM('earthquake', 'tsunami', 'forest_fire', 'citizen_report', 'fundraising', 'system') NOT NULL,
  `priority` ENUM('normal', 'high', 'critical') NOT NULL DEFAULT 'normal',
  `title` VARCHAR(200) NOT NULL,
  `body` TEXT NOT NULL,
  `distance_km` DECIMAL(7,2) NULL DEFAULT NULL COMMENT 'Jarak lokasi pengguna/pantauan ke titik bencana (km)',
  `payload_json` JSON NULL COMMENT 'Deep-link dan tautan catatan mitigasi terkait',
  `delivery_status` ENUM('queued', 'sent', 'failed', 'skipped') NOT NULL DEFAULT 'queued',
  `fcm_message_id` VARCHAR(191) NULL DEFAULT NULL,
  `sent_at` TIMESTAMP NULL DEFAULT NULL,
  `read_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_alert_user_read` (`user_id`, `read_at`, `created_at`),
  KEY `idx_alert_delivery` (`delivery_status`, `created_at`),
  KEY `idx_alert_event` (`disaster_event_id`),
  CONSTRAINT `fk_alert_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_alert_disaster_event` FOREIGN KEY (`disaster_event_id`) REFERENCES `disaster_events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_alert_monitored_loc` FOREIGN KEY (`monitored_location_id`) REFERENCES `user_monitored_locations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Riwayat notifikasi berbasis lokasi, status FCM, dan status baca pengguna';

-- ============================================================================
-- DOMAIN 4: LAPORAN WARGA & VERIFIKASI PETUGAS (3 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `citizen_reports` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `reporter_id` BIGINT UNSIGNED NOT NULL,
  `linked_disaster_event_id` BIGINT UNSIGNED NULL DEFAULT NULL COMMENT 'Kaitan ke event peta setelah diverifikasi petugas',
  `disaster_type` ENUM('earthquake', 'tsunami', 'forest_fire') NOT NULL,
  `report_category` ENUM('tremor_felt', 'tsunami_sign', 'smoke_haze', 'active_fire', 'infrastructure_damage', 'evacuation_needed', 'casualty') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `severity` ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `location_point` POINT NOT NULL SRID 4326,
  `address_text` VARCHAR(255) NULL DEFAULT NULL,
  `affected_people_estimate` INT UNSIGNED NULL DEFAULT NULL,
  `status` ENUM('pending', 'under_review', 'verified', 'rejected', 'resolved') NOT NULL DEFAULT 'pending',
  `verified_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `verification_notes` TEXT NULL,
  `verified_at` TIMESTAMP NULL DEFAULT NULL,
  `reported_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  SPATIAL KEY `sidx_citizen_reports_location` (`location_point`),
  KEY `idx_report_status_type` (`status`, `disaster_type`, `reported_at`),
  KEY `idx_report_reporter` (`reporter_id`, `created_at`),
  KEY `idx_report_verifier` (`verified_by`),
  CONSTRAINT `fk_report_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_report_linked_event` FOREIGN KEY (`linked_disaster_event_id`) REFERENCES `disaster_events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_report_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Laporan kondisi lapangan dari warga beserta status verifikasi petugas';

CREATE TABLE IF NOT EXISTS `citizen_report_media` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizen_report_id` BIGINT UNSIGNED NOT NULL,
  `media_type` ENUM('image', 'video') NOT NULL DEFAULT 'image',
  `file_path` VARCHAR(255) NOT NULL,
  `file_url` VARCHAR(255) NOT NULL,
  `mime_type` VARCHAR(80) NOT NULL,
  `file_size_bytes` INT UNSIGNED NOT NULL DEFAULT 0,
  `caption` VARCHAR(255) NULL DEFAULT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_report_media_order` (`citizen_report_id`, `sort_order`),
  CONSTRAINT `fk_report_media_report` FOREIGN KEY (`citizen_report_id`) REFERENCES `citizen_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lampiran foto atau video bukti lapangan dari laporan warga';

CREATE TABLE IF NOT EXISTS `report_verification_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizen_report_id` BIGINT UNSIGNED NOT NULL,
  `actor_id` BIGINT UNSIGNED NOT NULL COMMENT 'Petugas/admin yang melakukan aksi verifikasi',
  `from_status` VARCHAR(30) NULL DEFAULT NULL,
  `to_status` VARCHAR(30) NOT NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_verif_log_report` (`citizen_report_id`, `created_at`),
  KEY `idx_verif_log_actor` (`actor_id`, `created_at`),
  CONSTRAINT `fk_verif_log_report` FOREIGN KEY (`citizen_report_id`) REFERENCES `citizen_reports` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_verif_log_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Jejak audit immutable setiap perubahan status verifikasi laporan warga';

-- ============================================================================
-- DOMAIN 5: PENGGALANGAN DANA & TRANSPARANSI PENYALURAN (6 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `fundraising_campaigns` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `creator_id` BIGINT UNSIGNED NOT NULL,
  `disaster_event_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `title` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(220) NOT NULL,
  `summary` VARCHAR(350) NOT NULL,
  `story` LONGTEXT NOT NULL,
  `banner_image_url` VARCHAR(255) NULL DEFAULT NULL,
  `beneficiary_name` VARCHAR(180) NOT NULL,
  `beneficiary_location` VARCHAR(180) NOT NULL,
  `target_amount` DECIMAL(15,2) NOT NULL,
  `collected_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total donasi terverifikasi',
  `disbursed_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total penyaluran terverifikasi admin',
  `donor_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `bank_name` VARCHAR(80) NOT NULL COMMENT 'Bank tujuan transfer manual',
  `bank_account_number` VARCHAR(60) NOT NULL,
  `bank_account_holder` VARCHAR(150) NOT NULL,
  `qris_image_url` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Opsional gambar QRIS statis kampanye',
  `supporting_document_url` VARCHAR(255) NULL DEFAULT NULL,
  `starts_at` TIMESTAMP NULL DEFAULT NULL,
  `ends_at` TIMESTAMP NOT NULL,
  `status` ENUM('draft', 'pending_approval', 'active', 'paused', 'completed', 'closed', 'rejected') NOT NULL DEFAULT 'pending_approval',
  `approved_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `approval_notes` TEXT NULL,
  `approved_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_campaign_slug` (`slug`),
  KEY `idx_campaign_status_ends` (`status`, `ends_at`),
  KEY `idx_campaign_creator` (`creator_id`, `status`),
  KEY `idx_campaign_disaster` (`disaster_event_id`),
  CONSTRAINT `fk_campaign_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_campaign_disaster` FOREIGN KEY (`disaster_event_id`) REFERENCES `disaster_events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_campaign_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Kampanye penggalangan dana oleh penggagas dengan pelacakan progres & rekening tujuan';

CREATE TABLE IF NOT EXISTS `donations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `campaign_id` BIGINT UNSIGNED NOT NULL,
  `donor_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `order_code` VARCHAR(64) NOT NULL,
  `donor_name` VARCHAR(150) NOT NULL,
  `donor_email` VARCHAR(191) NULL DEFAULT NULL,
  `is_anonymous` TINYINT(1) NOT NULL DEFAULT 0,
  `amount` DECIMAL(15,2) NOT NULL,
  `payment_method` ENUM('manual_transfer', 'simulation') NOT NULL DEFAULT 'manual_transfer' COMMENT 'Transfer manual dengan bukti bayar atau mode simulasi uji',
  `payment_channel` VARCHAR(60) NULL DEFAULT NULL COMMENT 'Contoh: Transfer BCA, Transfer BRI, QRIS Manual, Simulasi Instan',
  `sender_bank_name` VARCHAR(80) NULL DEFAULT NULL,
  `sender_account_name` VARCHAR(120) NULL DEFAULT NULL,
  `payment_proof_url` VARCHAR(255) NULL DEFAULT NULL COMMENT 'URL bukti transfer yang diunggah donatur',
  `payment_proof_note` VARCHAR(255) NULL DEFAULT NULL,
  `payment_status` ENUM('pending', 'awaiting_verification', 'verified', 'rejected', 'expired') NOT NULL DEFAULT 'pending',
  `verified_by` BIGINT UNSIGNED NULL DEFAULT NULL COMMENT 'Admin yang memverifikasi bukti transfer manual',
  `verification_notes` TEXT NULL,
  `verified_at` TIMESTAMP NULL DEFAULT NULL,
  `message` TEXT NULL COMMENT 'Doa atau pesan dukungan donatur',
  `paid_at` TIMESTAMP NULL DEFAULT NULL,
  `expires_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_donation_order_code` (`order_code`),
  KEY `idx_donation_campaign_status` (`campaign_id`, `payment_status`),
  KEY `idx_donation_donor` (`donor_id`, `created_at`),
  KEY `idx_donation_verif_queue` (`payment_status`, `created_at`),
  CONSTRAINT `fk_donation_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `fundraising_campaigns` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_donation_donor` FOREIGN KEY (`donor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_donation_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Transaksi donasi melalui transfer manual terverifikasi admin atau mode simulasi';

CREATE TABLE IF NOT EXISTS `fund_disbursements` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `campaign_id` BIGINT UNSIGNED NOT NULL,
  `submitted_by` BIGINT UNSIGNED NOT NULL COMMENT 'Penggagas kampanye pelapor penyaluran',
  `disbursement_code` VARCHAR(64) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `disbursement_date` DATE NOT NULL,
  `recipient_group` VARCHAR(180) NOT NULL,
  `recipient_location` VARCHAR(180) NOT NULL,
  `beneficiary_count` INT UNSIGNED NULL DEFAULT NULL,
  `verification_status` ENUM('pending_verification', 'verified', 'rejected') NOT NULL DEFAULT 'pending_verification' COMMENT 'Wajib diverifikasi admin demi transparansi',
  `verified_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `verification_notes` TEXT NULL,
  `verified_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_disbursement_code` (`disbursement_code`),
  KEY `idx_disbursement_campaign_verif` (`campaign_id`, `verification_status`),
  KEY `idx_disbursement_verif_queue` (`verification_status`, `created_at`),
  CONSTRAINT `fk_disbursement_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `fundraising_campaigns` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_disbursement_submitter` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_disbursement_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Laporan penyaluran dana kampanye yang diverifikasi admin untuk transparansi';

CREATE TABLE IF NOT EXISTS `disbursement_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `disbursement_id` BIGINT UNSIGNED NOT NULL,
  `item_name` VARCHAR(180) NOT NULL,
  `category` ENUM('food_water', 'medical', 'shelter', 'clothing', 'logistics', 'recovery', 'other') NOT NULL DEFAULT 'other',
  `quantity` DECIMAL(10,2) NOT NULL,
  `unit` VARCHAR(30) NOT NULL,
  `unit_price` DECIMAL(15,2) NOT NULL,
  `subtotal` DECIMAL(15,2) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_disb_item_parent` (`disbursement_id`),
  CONSTRAINT `fk_disb_item_disbursement` FOREIGN KEY (`disbursement_id`) REFERENCES `fund_disbursements` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Rincian item pengeluaran penyaluran dana bencana';

CREATE TABLE IF NOT EXISTS `disbursement_evidences` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `disbursement_id` BIGINT UNSIGNED NOT NULL,
  `evidence_type` ENUM('receipt', 'bank_transfer', 'handover_photo', 'official_report') NOT NULL,
  `file_path` VARCHAR(255) NOT NULL,
  `file_url` VARCHAR(255) NOT NULL,
  `caption` VARCHAR(255) NULL DEFAULT NULL,
  `uploaded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_disb_evidence_parent` (`disbursement_id`),
  CONSTRAINT `fk_disb_evidence_disbursement` FOREIGN KEY (`disbursement_id`) REFERENCES `fund_disbursements` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bukti nota, transfer, foto serah terima, dan berita acara penyaluran dana';

CREATE TABLE IF NOT EXISTS `campaign_updates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `campaign_id` BIGINT UNSIGNED NOT NULL,
  `author_id` BIGINT UNSIGNED NOT NULL,
  `disbursement_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `image_url` VARCHAR(255) NULL DEFAULT NULL,
  `published_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_campaign_updates_pub` (`campaign_id`, `published_at`),
  CONSTRAINT `fk_update_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `fundraising_campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_update_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_update_disbursement` FOREIGN KEY (`disbursement_id`) REFERENCES `fund_disbursements` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Timeline kabar terbaru progres penggalangan dan penyaluran dana';

-- ============================================================================
-- DOMAIN 6: CATATAN MITIGASI BENCANA & KONTAK DARURAT (4 Tabel)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `mitigation_guides` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `disaster_type` ENUM('earthquake', 'tsunami', 'forest_fire') NOT NULL,
  `phase` ENUM('before', 'during', 'after') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(220) NOT NULL,
  `summary` VARCHAR(350) NOT NULL,
  `content` LONGTEXT NOT NULL,
  `icon_name` VARCHAR(80) NULL DEFAULT NULL,
  `priority_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `source_reference` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Rujukan resmi BNPB / BMKG / KLHK',
  `is_published` TINYINT(1) NOT NULL DEFAULT 1,
  `created_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `updated_by` BIGINT UNSIGNED NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mitigation_slug` (`slug`),
  KEY `idx_mitigation_type_phase` (`disaster_type`, `phase`, `priority_order`),
  CONSTRAINT `fk_mitigation_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mitigation_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Catatan dan panduan mitigasi bencana per jenis bencana dan fase pra/saat/pasca';

CREATE TABLE IF NOT EXISTS `mitigation_steps` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `mitigation_guide_id` BIGINT UNSIGNED NOT NULL,
  `step_number` TINYINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `instruction` TEXT NOT NULL,
  `is_critical_action` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Tandai aksi darurat prioritas utama',
  `illustration_url` VARCHAR(255) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mitigation_guide_step` (`mitigation_guide_id`, `step_number`),
  CONSTRAINT `fk_step_guide` FOREIGN KEY (`mitigation_guide_id`) REFERENCES `mitigation_guides` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Langkah-langkah terurut tindakan mitigasi di setiap panduan';

CREATE TABLE IF NOT EXISTS `user_mitigation_checklists` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `mitigation_step_id` BIGINT UNSIGNED NOT NULL,
  `is_completed` TINYINT(1) NOT NULL DEFAULT 0,
  `completed_at` TIMESTAMP NULL DEFAULT NULL,
  `personal_note` VARCHAR(255) NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_mitigation_step` (`user_id`, `mitigation_step_id`),
  CONSTRAINT `fk_checklist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_checklist_step` FOREIGN KEY (`mitigation_step_id`) REFERENCES `mitigation_steps` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Pelacakan checklist kesiapsiagaan mitigasi pribadi per pengguna';

CREATE TABLE IF NOT EXISTS `emergency_contacts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `agency` VARCHAR(100) NOT NULL,
  `phone_number` VARCHAR(30) NOT NULL,
  `disaster_scope` ENUM('all', 'earthquake', 'tsunami', 'forest_fire') NOT NULL DEFAULT 'all',
  `province` VARCHAR(100) NULL DEFAULT NULL COMMENT 'NULL menandakan hotline tingkat nasional',
  `description` VARCHAR(255) NULL DEFAULT NULL,
  `is_national` TINYINT(1) NOT NULL DEFAULT 0,
  `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_emergency_scope_prov` (`disaster_scope`, `province`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Direktori kontak darurat nasional dan daerah (BNPB, Basarnas, Damkar, BPBD)';
