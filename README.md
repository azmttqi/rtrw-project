# RT/RW Management System

Sistem Informasi Manajemen RT/RW (Rukun Tetangga/Rukun Warga) berbasis API menggunakan Node.js (Express) dan PostgreSQL. Proyek ini memfasilitasi administrasi warga, iuran, pengumuman, fasilitas, dan surat menyurat.

## 🚀 Prasyarat Sistem

Sebelum menjalankan proyek ini, pastikan Anda telah menginstal perangkat lunak berikut di sistem Anda:
- [Node.js](https://nodejs.org/) (Versi 16 atau lebih baru)
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/) (Untuk database)
- [Git](https://git-scm.com/)

---

## 🛠️ Instruksi Instalasi & Setup

### 1. Clone Repositori
Clone proyek ini ke dalam direktori lokal Anda:
```bash
git clone <url-repo-anda>
cd project-rtrw
```

### 2. Setup Environment Variables (.env)
Aplikasi ini membutuhkan file konfigurasi *environment variables* (`.env`). Namun, **file `.env` bersifat RAHASIA dan tidak boleh dipublikasikan (di-push ke repositori publik)**. Oleh karena itu, file ini sudah di-ignore melalui `.gitignore`.

Ikuti langkah berikut untuk men-setup variabel environment:
1. Masuk ke folder `backend`.
```bash
cd backend
```
2. Salin template `.env.example` yang disediakan menjadi `.env`.
```bash
cp .env.example .env
```
3. Buka file `.env` yang baru saja dibuat, lalu isi variabel-variabel di dalamnya sesuai konfigurasi lokal Anda (seperti password database, port, JWT secret, dll). 
> **Penting:** Pastikan Anda mengubah `JWT_SECRET`  untuk kebutuhan produksi agar sistem aman. Jangan membocorkan isi file `.env` Anda kepada siapa pun atau menyalin kemari isi lengkap kredensial Anda.

*(Catatan khusus: Docker Compose nantinya juga akan otomatis membaca file `backend/.env` ini untuk mengonfigurasi kredensial PostgreSQL Anda ketika *container* dijalankan.)*

### 3. Setup Database (Docker)
Proyek ini menggunakan Docker untuk menjalankan database PostgreSQL agar instalasi lebih mudah dan terisolasi. Skema database (tabel, enum, trigger) sudah disiapkan dalam file `database/rtrw.sql` dan akan dieksekusi (/di-seed) secara otomatis ketika *container* pertama kali dijalankan.

Pastikan Docker sudah berjalan di sistem Anda, lalu eksekusi perintah berikut **dari direktori root proyek (`project-rtrw`)**:
```bash
# Kembali ke root folder jika Anda berada di folder backend
cd .. 

# Jalankan kontainer database di background
docker-compose up -d
```
Jika kontainer berhasil berjalan, database PostgreSQL akan dapat diakses di `localhost` pada port yang sesuai dengan konfigurasi Anda (misalnya port `5433` berdasarkan default `.env.example`).

### 4. Menjalankan Backend Server
Setelah database siap, langkah selanjutnya adalah menginstal dependensi dan menjalankan server Node.js.

1. Masuk kembali ke folder `backend`:
```bash
cd backend
```
2. Instal semua dependensi menggunakan `npm`:
```bash
npm install
```
3. Jalankan aplikasi pada mode *development*:
```bash
npm run dev
```
Server akan berjalan dan secara default dapat diakses di: **`http://localhost:3000`** (atau sesuaikan dengan port pada `PORT` di `.env`).

Untuk mengecek apakah server telah berjalan dengan baik, akses URL *Health Check* berikut di browser atau aplikasi seperti Postman:
```
GET http://localhost:3000/health
```

---

## 📁 Struktur Folder Utama

```text
project-rtrw/
├── backend/            # Source code API (Node.js/Express)
│   ├── src/            # Logika utama (Controllers, Routes, Services, dll)
│   ├── .env.example    # Template environment variables
│   └── package.json    # Daftar dependensi backend
├── database/           # File inisialisasi database
│   └── rtrw.sql        # Skema awal database (Otomatis dijalankan oleh Docker)
├── docker-compose.yml  # Konfigurasi container Service (PostgreSQL)
└── README.md           # Dokumentasi proyek
```

## 🔐 Autentikasi API
Aplikasi ini menggunakan JSON Web Token (JWT) untuk melindungi endpoint. Token JWT didapatkan ketika pengguna (Warga/RT/RW) melakukan proses *Login*, dan lalu harus disertakan pada HTTP Header `Authorization` sebagai `Bearer Token` untuk setiap *request* yang membutuhkan batasan akses.

---

## 🗺️ Rencana Pengembangan (Roadmap)
Saat ini proyek telah menyelesaikan pengembangan inti **Backend API** dan **Database** (Phase 1 & 2). 

Tahap pengembangan **Frontend** (Phase 3) menggunakan Flutter telah dimulai. Fokus saat ini adalah membangun antarmuka pengguna (UI) dan integrasi dengan API yang sudah tersedia. Seluruh detail rencana pengembangan dapat dilihat pada file [ROADMAP.md](file:///d:/kuliah/project-rtrw/ROADMAP.md).
