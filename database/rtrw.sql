-- =====================================================
-- ENUM TYPES
-- =====================================================

-- Role Akun
CREATE TYPE role_akun AS ENUM ('WARGA', 'RT', 'RW');

-- Status Verifikasi
CREATE TYPE status_verifikasi AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- Kategori Warga
CREATE TYPE tipe_warga AS ENUM ('LAMA', 'BARU');
CREATE TYPE status_tinggal AS ENUM ('TETAP', 'SEWA');
CREATE TYPE status_pernikahan AS ENUM ('BELUM_KAWIN', 'KAWIN', 'CERAI_HIDUP', 'CERAI_MATI');
CREATE TYPE jenis_kelamin AS ENUM ('LAKI_LAKI', 'PEREMPUAN');

-- Status Surat
CREATE TYPE status_surat AS ENUM ('PENDING_RT', 'REJECTED_RT', 'APPROVED_RT_PENDING_RW', 'REJECTED_RW', 'APPROVED_RW');

-- Transaksi Keuangan
CREATE TYPE tipe_transaksi AS ENUM ('PEMASUKAN', 'PENGELUARAN');

-- Target Pengumuman
CREATE TYPE target_pengumuman AS ENUM ('SEMUA_RW', 'SEMUA_RT', 'WARGA_RT');

-- Tingkat Iuran
CREATE TYPE tingkat_iuran AS ENUM ('WARGA', 'RT');

-- Status Laporan
CREATE TYPE status_laporan AS ENUM ('PENDING', 'DIPROSES', 'SELESAI', 'DITOLAK');

-- =====================================================
-- TABEL WILAYAH
-- =====================================================

-- RW (Rukun Warga)
CREATE TABLE rws (
    id SERIAL PRIMARY KEY,
    nomor_rw VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_rw UNIQUE (nomor_rw)
);

-- RT (Rukun Tetangga)
CREATE TABLE rts (
    id SERIAL PRIMARY KEY,
    rw_id INT REFERENCES rws(id) ON DELETE CASCADE,
    nomor_rt VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_rt_per_rw UNIQUE (rw_id, nomor_rt)
);

-- =====================================================
-- USER LOGIN SYSTEM
-- =====================================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(150),
    no_wa VARCHAR(20) UNIQUE, -- Menjadi nullable untuk mendukung login Google (RT/RW)
    email VARCHAR(150) UNIQUE, -- Ditambahkan untuk login Google
    google_id VARCHAR(255) UNIQUE, -- Ditambahkan untuk login Google
    password_hash TEXT, -- Menjadi nullable untuk akun Google
    role role_akun NOT NULL,

    rt_id INT REFERENCES rts(id) ON DELETE SET NULL,
    rw_id INT REFERENCES rws(id) ON DELETE SET NULL,

    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INVITATION SYSTEM
-- =====================================================

CREATE TABLE invitations (
    id SERIAL PRIMARY KEY,
    no_wa VARCHAR(20), -- Menjadi nullable untuk mendukung RT via Google (Link saja)
    rt_id INT REFERENCES rts(id) ON DELETE CASCADE,
    rw_id INT REFERENCES rws(id) ON DELETE CASCADE, -- Tambahkan untuk undangan RT dari RW
    token VARCHAR(255) NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '7 days'), -- Diperpanjang menjadi 7 hari
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_invitation_target CHECK (
        (rt_id IS NOT NULL AND rw_id IS NULL) OR
        (rt_id IS NULL AND rw_id IS NOT NULL)
    )
);

-- =====================================================
-- FAMILY (1 AKUN = 1 KK)
-- =====================================================

CREATE TABLE families (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    rt_id INT REFERENCES rts(id),

    no_kk VARCHAR(20) UNIQUE NOT NULL,
    tipe_warga tipe_warga NOT NULL,
    status_tinggal status_tinggal NOT NULL,
    status_pernikahan status_pernikahan,

    status_verifikasi status_verifikasi DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- DOKUMEN WARGA
-- =====================================================

CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    family_id INT REFERENCES families(id) ON DELETE CASCADE,
    jenis_dokumen VARCHAR(50) NOT NULL,
    file_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jenis dokumen contoh:
-- KK, KTP, KTP_PEMILIK_RUMAH, SURAT_SEWA, BUKU_NIKAH, SURAT_PINDAH, SURAT_PENGANTAR

-- =====================================================
-- ANGGOTA KELUARGA
-- =====================================================

CREATE TABLE residents (
    id SERIAL PRIMARY KEY,
    family_id INT REFERENCES families(id) ON DELETE CASCADE,

    nik VARCHAR(20) UNIQUE NOT NULL,
    nama_lengkap VARCHAR(150) NOT NULL,
    jenis_kelamin jenis_kelamin NOT NULL,
    tanggal_lahir DATE NOT NULL,
    hubungan_keluarga VARCHAR(50) NOT NULL
);

-- =====================================================
-- RIWAYAT PINDAH RT/RW
-- =====================================================

CREATE TABLE family_rt_history (
    id SERIAL PRIMARY KEY,

    family_id INT REFERENCES families(id) ON DELETE CASCADE,
    rt_id INT REFERENCES rts(id),

    mulai_tanggal DATE NOT NULL,
    selesai_tanggal DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PENGUMUMAN
-- =====================================================

CREATE TABLE announcements (
    id SERIAL PRIMARY KEY,
    pembuat_user_id INT REFERENCES users(id),

    target target_pengumuman NOT NULL,
    target_rt_id INT REFERENCES rts(id),

    judul VARCHAR(255) NOT NULL,
    konten TEXT NOT NULL,

    is_kegiatan BOOLEAN DEFAULT FALSE,
    tanggal_kegiatan DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FASILITAS
-- =====================================================

CREATE TABLE facilities (
    id SERIAL PRIMARY KEY,
    rt_id INT REFERENCES rts(id) ON DELETE CASCADE,

    nama_fasilitas VARCHAR(150) NOT NULL,
    deskripsi TEXT,
    foto_url TEXT,

    alamat TEXT,
    koordinat_maps_url TEXT,
    bisa_dipinjam BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PEMINJAMAN FASILITAS
-- =====================================================

CREATE TABLE facility_reservations (
    id SERIAL PRIMARY KEY,
    facility_id INT REFERENCES facilities(id) ON DELETE CASCADE,
    peminjam_user_id INT REFERENCES users(id),

    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    keterangan TEXT,

    status status_verifikasi DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_tanggal CHECK (tanggal_selesai >= tanggal_mulai)
);

-- =====================================================
-- CCTV
-- =====================================================

CREATE TABLE cctvs (
    id SERIAL PRIMARY KEY,
    rt_id INT REFERENCES rts(id) ON DELETE CASCADE,
    nama_cctv VARCHAR(100) NOT NULL,
    stream_url TEXT NOT NULL
);

-- =====================================================
-- SURAT MENYURAT
-- =====================================================

CREATE TABLE letters (
    id SERIAL PRIMARY KEY,
    family_id INT REFERENCES families(id) ON DELETE CASCADE,

    jenis_surat VARCHAR(100) NOT NULL,
    keterangan_keperluan TEXT NOT NULL,

    status status_surat DEFAULT 'PENDING_RT',
    dokumen_hasil_url TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PENGATURAN IURAN
-- =====================================================

CREATE TABLE dues_settings (
    id SERIAL PRIMARY KEY,

    tingkat tingkat_iuran NOT NULL,
    
    rt_id INT REFERENCES rts(id) ON DELETE CASCADE,
    rw_id INT REFERENCES rws(id) ON DELETE CASCADE,

    nominal DECIMAL(12,2) NOT NULL,
    tenggat_tanggal INT NOT NULL CHECK (tenggat_tanggal >= 1 AND tenggat_tanggal <= 31),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_dues_setting CHECK (
        (rt_id IS NOT NULL AND rw_id IS NULL)
        OR
        (rt_id IS NULL AND rw_id IS NOT NULL)
    )
);

-- =====================================================
-- PEMBAYARAN IURAN
-- =====================================================

CREATE TABLE dues_payments (
    id SERIAL PRIMARY KEY,

    pembayar_family_id INT REFERENCES families(id),
    pembayar_rt_id INT REFERENCES rts(id),

    bulan INT NOT NULL CHECK (bulan >= 1 AND bulan <= 12),
    tahun INT NOT NULL,
    nominal DECIMAL(12,2) NOT NULL,

    metode_bayar VARCHAR(20),
    bukti_bayar_url TEXT,

    status status_verifikasi DEFAULT 'PENDING',

    dibayar_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pembayar CHECK (
        (pembayar_family_id IS NOT NULL AND pembayar_rt_id IS NULL)
        OR
        (pembayar_family_id IS NULL AND pembayar_rt_id IS NOT NULL)
    )
);

-- =====================================================
-- TAGIHAN IURAN OTOMATIS
-- =====================================================

CREATE TABLE dues_bills (
    id SERIAL PRIMARY KEY,

    family_id INT REFERENCES families(id) ON DELETE CASCADE,

    bulan INT NOT NULL CHECK (bulan >= 1 AND bulan <= 12),
    tahun INT NOT NULL,

    nominal DECIMAL(12,2) NOT NULL,

    status status_verifikasi DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unique_bill_per_family UNIQUE (family_id, bulan, tahun)
);

-- =====================================================
-- BUKU KAS
-- =====================================================

CREATE TABLE finances (
    id SERIAL PRIMARY KEY,

    rt_id INT REFERENCES rts(id),
    rw_id INT REFERENCES rws(id),

    tipe tipe_transaksi NOT NULL,
    nominal DECIMAL(12,2) NOT NULL,
    keterangan TEXT NOT NULL,

    bukti_nota_url TEXT,
    tanggal_transaksi DATE NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_finance CHECK (
        (rt_id IS NOT NULL AND rw_id IS NULL)
        OR
        (rt_id IS NULL AND rw_id IS NOT NULL)
    )
);

-- =====================================================
-- NOTIFICATION SYSTEM
-- =====================================================

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,

    user_id INT REFERENCES users(id),

    title VARCHAR(255),
    message TEXT,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- LAPORAN WARGA (COMPLAINTS)
-- =====================================================

CREATE TABLE complaints (
    id SERIAL PRIMARY KEY,

    pelapor_user_id INT REFERENCES users(id),

    rt_id INT REFERENCES rts(id),

    judul VARCHAR(255) NOT NULL,
    deskripsi TEXT NOT NULL,

    foto_url TEXT,

    status status_laporan DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES (Untuk Performa Query)
-- =====================================================

CREATE INDEX idx_users_rt ON users(rt_id);
CREATE INDEX idx_users_rw ON users(rw_id);
CREATE INDEX idx_families_rt ON families(rt_id);
CREATE INDEX idx_residents_family ON residents(family_id);
CREATE INDEX idx_residents_nik ON residents(nik);
CREATE INDEX idx_dues_family ON dues_payments(pembayar_family_id);
CREATE INDEX idx_dues_rt ON dues_payments(pembayar_rt_id);
CREATE INDEX idx_letters_family ON letters(family_id);
CREATE INDEX idx_announcements_target ON announcements(target, target_rt_id);
CREATE INDEX idx_invitations_token ON invitations(token);
CREATE INDEX idx_invitations_rt ON invitations(rt_id);

-- =====================================================
-- TRIGGERS (Untuk Auto Update updated_at)
-- =====================================================

-- Function untuk auto update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger untuk letters
CREATE TRIGGER update_letters_updated_at
    BEFORE UPDATE ON letters
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger untuk complaints
CREATE TRIGGER update_complaints_updated_at
    BEFORE UPDATE ON complaints
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- TAMBAHAN INDEXES UNTUK FITUR BARU
-- =====================================================

CREATE INDEX idx_dues_bills_family ON dues_bills(family_id);
CREATE INDEX idx_family_rt_history_family ON family_rt_history(family_id);
CREATE INDEX idx_complaints_rt ON complaints(rt_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_facility_reservations_facility ON facility_reservations(facility_id);

-- Trigger untuk facility_reservations
CREATE TRIGGER update_facility_reservations_updated_at
    BEFORE UPDATE ON facility_reservations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

