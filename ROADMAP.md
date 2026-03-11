# Development Roadmap: Sistem Manajemen RT/RW

Berikut adalah rencana pengembangan sistem informasi manajemen RT/RW dari tahap inisialisasi hingga tahap produksi.

## Overview Phases

| Phase | Nama Tahapan | Fokus Pekerjaan | Output Utama (Deliverables) |
|---|---|---|---|
| **Phase 0** | **Initiation & Planning** | Perencanaan awal, perancangan database, & struktur repositori. | • Dokumen Kebutuhan Sistem<br>• Desain Skema Database<br>• Setup Repositori Git |
| **Phase 1** | **Backend & Database Foundation** | Inisialisasi server Node.js/Express dan konektivitas Database PostgreSQL. | • Skrip SQL Migrasi/Seed (`rtrw.sql`)<br>• Konfigurasi Docker PostgreSQL<br>• Backend Server Node.js berjalan |
| **Phase 2** | **Core API Development & Authentication** | Pembuatan semua Endpoint API (CRUD) & sistem keamanan (JWT). | • API Autentikasi (Login/Token)<br>• API Warga, Iuran, Pengumuman, Fasilitas, & Surat<br>• Fitur keamanan Role-Based Access |
| **Phase 3** | **Frontend Development (Flutter)** | Pengembangan aplikasi Mobile/Web menggunakan Flutter. | • Aplikasi Mobile/Web Warga<br>• Dashboard Admin (RT/RW)<br>• Integrasi UI dengan Backend API |
| **Phase 4** | **Testing, Security & Optimization** | Pengujian menyeluruh dan penambalan celah keamanan. | • Laporan Unit Test / Integration Test<br>• UAT (User Acceptance Test) disetujui<br>• Aplikasi bebas bug kritis & aman |
| **Phase 5** | **Deployment & Production (Go-Live)** | Membawa sistem ke *environment* publik yang dapat diakses siap pakai. | • Backend & DB di Server Cloud (VPS)<br>• SSL & Custom Domain Terpasang<br>• Sistem Monitor Produksi (Logging) |

---

## Phase 0: Initiation & Planning
Tahap awal untuk mendefinisikan ruang lingkup, arsitektur, dan kebutuhan sistem.

- [x] **Requirement Gathering**: Mengumpulkan kebutuhan dari pengurus RT/RW terkait administrasi warga, iuran, pengumuman, fasilitas, dan persuratan.
- [x] **System Architecture Design**: Menentukan stack teknologi (Node.js, Express, PostgreSQL, Docker untuk database).
- [x] **Database Schema Design**: Merancang entitas (Warga, Keluarga, Iuran, Pengumuman, Fasilitas, Surat) dan relasinya.
- [x] **Repository Setup**: Inisialisasi Git repository dan struktur folder (*backend* dan *database*).

## Phase 1: Backend & Database Foundation
Implementasi struktur dasar backend API dan setup database.

- [x] **Database Setup**: Pembuatan skema SQL (`rtrw.sql`) dan konfigurasi Docker Compose untuk PostgreSQL.
- [x] **Backend Skeleton**: Konfigurasi server Node.js dengan Express.js.
- [x] **Environment Configuration**: Setup `.env` untuk manajemen konfigurasi.
- [x] **Database Connection**: Implementasi koneksi dari Node.js ke PostgreSQL.
- [x] **Error Handling & Middleware**: Setup middleware standar (CORS, body parser, error handler).

## Phase 2: Core API Development & Authentication
Membangun fitur utama pada sisi Backend.

- [x] **Authentication & Authorization**: Implementasi Login menggunakan JWT dan Role-based Access Control (Role: Admin/RT/RW, Warga).
- [x] **Manajemen Warga & Keluarga (CRUD)**: API untuk pendaftaran, update data, dan pencarian warga.
- [x] **Manajemen Iuran & Keuangan**: API untuk mencatat pembayaran iuran bulanan dan laporan kas.
- [x] **Manajemen Pengumuman**: API untuk membuat dan menyebarkan pengumuman/berita kepada warga.
- [ ] **Manajemen Fasilitas**: API untuk peminjaman dan penjadwalan fasilitas publik RT/RW.
- [ ] **Layanan Surat Menyurat**: API untuk request surat pengantar oleh warga dan persetujuan oleh RT/RW.

## Phase 3: Frontend Development (Admin & User Portals)
Membangun antarmuka pengguna setelah Backend API stabil.

- [ ] **Frontend Setup**: Inisialisasi proyek Frontend Mobile/Web menggunakan framework Flutter.
- [ ] **UI/UX System Design**: Pembuatan layout dasar, navigasi, dan tema komponen.
- [ ] **Admin Dashboard Integration**: Halaman khusus pengurus untuk mengelola warga, memvalidasi persuratan, dan memonitor kas.
- [ ] **User Portal Integration**: Halaman warga untuk melihat tagihan iuran, mengajukan surat, dan membaca pengumuman.
- [ ] **Responsive Design Alignment**: Memastikan tampilan optimal di perangkat desktop maupun *mobile*.

## Phase 4: Testing, Security & Optimization
Memastikan sistem berjalan lancar, aman, dan tanpa celah.

- [ ] **Unit & Integration Testing**: Menulis *test script* pada endpoint API kritis (seperti transaksi keuangan dan surat).
- [ ] **Security Review**: Menerapkan *rate limiting*, proteksi XSS, *SQL injection prevention*, dan enkripsi password (hash).
- [ ] **UAT (User Acceptance Testing)**: Mengujicoba alur aplikasi bersama beberapa perwakilan warga dan pengurus RT.
- [ ] **Bug Fixing & Refactoring**: Memperbaiki isu yang ditemukan selama UAT.

## Phase 5: Deployment & Production (Go-Live)
Tahap peluncuran sistem agar dapat digunakan secara riil.

- [ ] **Cloud Infrastructure Setup**: Memilah layanan *hosting/cloud* (contoh: AWS, DigitalOcean, atau VPS lokal) untuk Backend, Database, dan Frontend.
- [ ] **CI/CD Pipeline Configuration**: Setup GitHub Actions / GitLab CI untuk otomasi *testing* dan *deployment*.
- [ ] **Domain & SSL**: Menautkan *custom domain* (misal: `rtrw-sejahtera.com`) dan memasang sertifikat SSL (HTTPS).
- [ ] **Production Monitoring Setup**: Pemasangan layanan *monitoring* (seperti PM2 untuk Node.js) dan sistem *logging*.
- [ ] **Go-Live & Handover**: Peluncuran resmi, pelatihan singkat untuk pengurus RT/RW, dan perilisan panduan *user guide*.
