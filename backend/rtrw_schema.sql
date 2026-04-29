--
-- PostgreSQL database dump
--

\restrict 09hdi3124h8eLQVn4o0celTtGv7whC1anYMSEUJqIhPEA2IP7ikCvnReMEr0wwF

-- Dumped from database version 15.17
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: jenis_kelamin; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.jenis_kelamin AS ENUM (
    'LAKI_LAKI',
    'PEREMPUAN'
);


ALTER TYPE public.jenis_kelamin OWNER TO postgres;

--
-- Name: role_akun; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.role_akun AS ENUM (
    'WARGA',
    'RT',
    'RW'
);


ALTER TYPE public.role_akun OWNER TO postgres;

--
-- Name: status_laporan; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_laporan AS ENUM (
    'PENDING',
    'DIPROSES',
    'SELESAI',
    'DITOLAK'
);


ALTER TYPE public.status_laporan OWNER TO postgres;

--
-- Name: status_pernikahan; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_pernikahan AS ENUM (
    'BELUM_KAWIN',
    'KAWIN',
    'CERAI_HIDUP',
    'CERAI_MATI'
);


ALTER TYPE public.status_pernikahan OWNER TO postgres;

--
-- Name: status_surat; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_surat AS ENUM (
    'PENDING_RT',
    'REJECTED_RT',
    'APPROVED_RT_PENDING_RW',
    'REJECTED_RW',
    'APPROVED_RW'
);


ALTER TYPE public.status_surat OWNER TO postgres;

--
-- Name: status_tinggal; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_tinggal AS ENUM (
    'TETAP',
    'SEWA'
);


ALTER TYPE public.status_tinggal OWNER TO postgres;

--
-- Name: status_verifikasi; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_verifikasi AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public.status_verifikasi OWNER TO postgres;

--
-- Name: target_pengumuman; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.target_pengumuman AS ENUM (
    'SEMUA_RW',
    'SEMUA_RT',
    'WARGA_RT'
);


ALTER TYPE public.target_pengumuman OWNER TO postgres;

--
-- Name: tingkat_iuran; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tingkat_iuran AS ENUM (
    'WARGA',
    'RT'
);


ALTER TYPE public.tingkat_iuran OWNER TO postgres;

--
-- Name: tipe_transaksi; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipe_transaksi AS ENUM (
    'PEMASUKAN',
    'PENGELUARAN'
);


ALTER TYPE public.tipe_transaksi OWNER TO postgres;

--
-- Name: tipe_warga; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipe_warga AS ENUM (
    'LAMA',
    'BARU'
);


ALTER TYPE public.tipe_warga OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    pembuat_user_id integer,
    target public.target_pengumuman NOT NULL,
    target_rt_id integer,
    judul character varying(255) NOT NULL,
    konten text NOT NULL,
    is_kegiatan boolean DEFAULT false,
    tanggal_kegiatan date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    foto_url text
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.announcements_id_seq OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: cctvs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cctvs (
    id integer NOT NULL,
    rt_id integer,
    nama_cctv character varying(100) NOT NULL,
    stream_url text NOT NULL
);


ALTER TABLE public.cctvs OWNER TO postgres;

--
-- Name: cctvs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cctvs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cctvs_id_seq OWNER TO postgres;

--
-- Name: cctvs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cctvs_id_seq OWNED BY public.cctvs.id;


--
-- Name: complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaints (
    id integer NOT NULL,
    pelapor_user_id integer,
    rt_id integer,
    judul character varying(255) NOT NULL,
    deskripsi text NOT NULL,
    foto_url text,
    status public.status_laporan DEFAULT 'PENDING'::public.status_laporan,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.complaints OWNER TO postgres;

--
-- Name: complaints_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.complaints_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.complaints_id_seq OWNER TO postgres;

--
-- Name: complaints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.complaints_id_seq OWNED BY public.complaints.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    family_id integer,
    jenis_dokumen character varying(50) NOT NULL,
    file_url text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: dues_bills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dues_bills (
    id integer NOT NULL,
    family_id integer,
    bulan integer NOT NULL,
    tahun integer NOT NULL,
    nominal numeric(12,2) NOT NULL,
    status public.status_verifikasi DEFAULT 'PENDING'::public.status_verifikasi,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dues_bills_bulan_check CHECK (((bulan >= 1) AND (bulan <= 12)))
);


ALTER TABLE public.dues_bills OWNER TO postgres;

--
-- Name: dues_bills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dues_bills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dues_bills_id_seq OWNER TO postgres;

--
-- Name: dues_bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dues_bills_id_seq OWNED BY public.dues_bills.id;


--
-- Name: dues_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dues_payments (
    id integer NOT NULL,
    pembayar_family_id integer,
    pembayar_rt_id integer,
    bulan integer NOT NULL,
    tahun integer NOT NULL,
    nominal numeric(12,2) NOT NULL,
    metode_bayar character varying(20),
    bukti_bayar_url text,
    status public.status_verifikasi DEFAULT 'PENDING'::public.status_verifikasi,
    dibayar_pada timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pembayar CHECK ((((pembayar_family_id IS NOT NULL) AND (pembayar_rt_id IS NULL)) OR ((pembayar_family_id IS NULL) AND (pembayar_rt_id IS NOT NULL)))),
    CONSTRAINT dues_payments_bulan_check CHECK (((bulan >= 1) AND (bulan <= 12)))
);


ALTER TABLE public.dues_payments OWNER TO postgres;

--
-- Name: dues_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dues_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dues_payments_id_seq OWNER TO postgres;

--
-- Name: dues_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dues_payments_id_seq OWNED BY public.dues_payments.id;


--
-- Name: dues_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dues_settings (
    id integer NOT NULL,
    tingkat public.tingkat_iuran NOT NULL,
    rt_id integer,
    rw_id integer,
    nominal numeric(12,2) NOT NULL,
    tenggat_tanggal integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_dues_setting CHECK ((((rt_id IS NOT NULL) AND (rw_id IS NULL)) OR ((rt_id IS NULL) AND (rw_id IS NOT NULL)))),
    CONSTRAINT dues_settings_tenggat_tanggal_check CHECK (((tenggat_tanggal >= 1) AND (tenggat_tanggal <= 31)))
);


ALTER TABLE public.dues_settings OWNER TO postgres;

--
-- Name: dues_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dues_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dues_settings_id_seq OWNER TO postgres;

--
-- Name: dues_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dues_settings_id_seq OWNED BY public.dues_settings.id;


--
-- Name: facilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facilities (
    id integer NOT NULL,
    rt_id integer,
    nama_fasilitas character varying(150) NOT NULL,
    deskripsi text,
    foto_url text,
    alamat text,
    koordinat_maps_url text,
    bisa_dipinjam boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.facilities OWNER TO postgres;

--
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facilities_id_seq OWNER TO postgres;

--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facilities_id_seq OWNED BY public.facilities.id;


--
-- Name: facility_reservations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_reservations (
    id integer NOT NULL,
    facility_id integer,
    peminjam_user_id integer,
    tanggal_mulai date NOT NULL,
    tanggal_selesai date NOT NULL,
    keterangan text,
    status public.status_verifikasi DEFAULT 'PENDING'::public.status_verifikasi,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tanggal CHECK ((tanggal_selesai >= tanggal_mulai))
);


ALTER TABLE public.facility_reservations OWNER TO postgres;

--
-- Name: facility_reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facility_reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facility_reservations_id_seq OWNER TO postgres;

--
-- Name: facility_reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facility_reservations_id_seq OWNED BY public.facility_reservations.id;


--
-- Name: families; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.families (
    id integer NOT NULL,
    user_id integer,
    rt_id integer,
    no_kk character varying(20) NOT NULL,
    tipe_warga public.tipe_warga NOT NULL,
    status_tinggal public.status_tinggal NOT NULL,
    status_pernikahan public.status_pernikahan,
    status_verifikasi public.status_verifikasi DEFAULT 'PENDING'::public.status_verifikasi,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.families OWNER TO postgres;

--
-- Name: families_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.families_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.families_id_seq OWNER TO postgres;

--
-- Name: families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.families_id_seq OWNED BY public.families.id;


--
-- Name: family_rt_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.family_rt_history (
    id integer NOT NULL,
    family_id integer,
    rt_id integer,
    mulai_tanggal date NOT NULL,
    selesai_tanggal date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.family_rt_history OWNER TO postgres;

--
-- Name: family_rt_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.family_rt_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.family_rt_history_id_seq OWNER TO postgres;

--
-- Name: family_rt_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.family_rt_history_id_seq OWNED BY public.family_rt_history.id;


--
-- Name: finances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finances (
    id integer NOT NULL,
    rt_id integer,
    rw_id integer,
    tipe public.tipe_transaksi NOT NULL,
    nominal numeric(12,2) NOT NULL,
    keterangan text NOT NULL,
    bukti_nota_url text,
    tanggal_transaksi date NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_finance CHECK ((((rt_id IS NOT NULL) AND (rw_id IS NULL)) OR ((rt_id IS NULL) AND (rw_id IS NOT NULL))))
);


ALTER TABLE public.finances OWNER TO postgres;

--
-- Name: finances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finances_id_seq OWNER TO postgres;

--
-- Name: finances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finances_id_seq OWNED BY public.finances.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invitations (
    id integer NOT NULL,
    no_wa character varying(20),
    rt_id integer,
    rw_id integer,
    token character varying(255) NOT NULL,
    is_used boolean DEFAULT false,
    expires_at timestamp without time zone DEFAULT (now() + '7 days'::interval),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_invitation_target CHECK ((((rt_id IS NOT NULL) AND (rw_id IS NULL)) OR ((rt_id IS NULL) AND (rw_id IS NOT NULL))))
);


ALTER TABLE public.invitations OWNER TO postgres;

--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invitations_id_seq OWNER TO postgres;

--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: letters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.letters (
    id integer NOT NULL,
    family_id integer,
    jenis_surat character varying(100) NOT NULL,
    keterangan_keperluan text NOT NULL,
    status public.status_surat DEFAULT 'PENDING_RT'::public.status_surat,
    dokumen_hasil_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.letters OWNER TO postgres;

--
-- Name: letters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.letters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.letters_id_seq OWNER TO postgres;

--
-- Name: letters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.letters_id_seq OWNED BY public.letters.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    title character varying(255),
    message text,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: residents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.residents (
    id integer NOT NULL,
    family_id integer,
    nik character varying(20) NOT NULL,
    nama_lengkap character varying(150) NOT NULL,
    jenis_kelamin public.jenis_kelamin NOT NULL,
    tanggal_lahir date NOT NULL,
    hubungan_keluarga character varying(50) NOT NULL
);


ALTER TABLE public.residents OWNER TO postgres;

--
-- Name: residents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.residents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.residents_id_seq OWNER TO postgres;

--
-- Name: residents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.residents_id_seq OWNED BY public.residents.id;


--
-- Name: rts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rts (
    id integer NOT NULL,
    rw_id integer,
    nomor_rt character varying(10) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rts OWNER TO postgres;

--
-- Name: rts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rts_id_seq OWNER TO postgres;

--
-- Name: rts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rts_id_seq OWNED BY public.rts.id;


--
-- Name: rws; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rws (
    id integer NOT NULL,
    nomor_rw character varying(10) NOT NULL,
    nama_wilayah character varying(150),
    alamat text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rws OWNER TO postgres;

--
-- Name: rws_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rws_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rws_id_seq OWNER TO postgres;

--
-- Name: rws_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rws_id_seq OWNED BY public.rws.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    nama character varying(150),
    no_wa character varying(20),
    email character varying(150),
    google_id character varying(255),
    password_hash text,
    role public.role_akun NOT NULL,
    rt_id integer,
    rw_id integer,
    is_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: cctvs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cctvs ALTER COLUMN id SET DEFAULT nextval('public.cctvs_id_seq'::regclass);


--
-- Name: complaints id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints ALTER COLUMN id SET DEFAULT nextval('public.complaints_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: dues_bills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_bills ALTER COLUMN id SET DEFAULT nextval('public.dues_bills_id_seq'::regclass);


--
-- Name: dues_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_payments ALTER COLUMN id SET DEFAULT nextval('public.dues_payments_id_seq'::regclass);


--
-- Name: dues_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_settings ALTER COLUMN id SET DEFAULT nextval('public.dues_settings_id_seq'::regclass);


--
-- Name: facilities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities ALTER COLUMN id SET DEFAULT nextval('public.facilities_id_seq'::regclass);


--
-- Name: facility_reservations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_reservations ALTER COLUMN id SET DEFAULT nextval('public.facility_reservations_id_seq'::regclass);


--
-- Name: families id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families ALTER COLUMN id SET DEFAULT nextval('public.families_id_seq'::regclass);


--
-- Name: family_rt_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family_rt_history ALTER COLUMN id SET DEFAULT nextval('public.family_rt_history_id_seq'::regclass);


--
-- Name: finances id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances ALTER COLUMN id SET DEFAULT nextval('public.finances_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: letters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letters ALTER COLUMN id SET DEFAULT nextval('public.letters_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: residents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.residents ALTER COLUMN id SET DEFAULT nextval('public.residents_id_seq'::regclass);


--
-- Name: rts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rts ALTER COLUMN id SET DEFAULT nextval('public.rts_id_seq'::regclass);


--
-- Name: rws id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rws ALTER COLUMN id SET DEFAULT nextval('public.rws_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: cctvs cctvs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cctvs
    ADD CONSTRAINT cctvs_pkey PRIMARY KEY (id);


--
-- Name: complaints complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: dues_bills dues_bills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_bills
    ADD CONSTRAINT dues_bills_pkey PRIMARY KEY (id);


--
-- Name: dues_payments dues_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_payments
    ADD CONSTRAINT dues_payments_pkey PRIMARY KEY (id);


--
-- Name: dues_settings dues_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_settings
    ADD CONSTRAINT dues_settings_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_reservations facility_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_reservations
    ADD CONSTRAINT facility_reservations_pkey PRIMARY KEY (id);


--
-- Name: families families_no_kk_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_no_kk_key UNIQUE (no_kk);


--
-- Name: families families_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_pkey PRIMARY KEY (id);


--
-- Name: families families_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_user_id_key UNIQUE (user_id);


--
-- Name: family_rt_history family_rt_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family_rt_history
    ADD CONSTRAINT family_rt_history_pkey PRIMARY KEY (id);


--
-- Name: finances finances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: letters letters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: residents residents_nik_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_nik_key UNIQUE (nik);


--
-- Name: residents residents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_pkey PRIMARY KEY (id);


--
-- Name: rts rts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rts
    ADD CONSTRAINT rts_pkey PRIMARY KEY (id);


--
-- Name: rws rws_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rws
    ADD CONSTRAINT rws_pkey PRIMARY KEY (id);


--
-- Name: dues_bills unique_bill_per_family; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_bills
    ADD CONSTRAINT unique_bill_per_family UNIQUE (family_id, bulan, tahun);


--
-- Name: rts unique_rt_per_rw; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rts
    ADD CONSTRAINT unique_rt_per_rw UNIQUE (rw_id, nomor_rt);


--
-- Name: rws unique_rw; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rws
    ADD CONSTRAINT unique_rw UNIQUE (nomor_rw);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- Name: users users_no_wa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_no_wa_key UNIQUE (no_wa);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_announcements_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target ON public.announcements USING btree (target, target_rt_id);


--
-- Name: idx_complaints_rt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_complaints_rt ON public.complaints USING btree (rt_id);


--
-- Name: idx_complaints_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_complaints_status ON public.complaints USING btree (status);


--
-- Name: idx_dues_bills_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dues_bills_family ON public.dues_bills USING btree (family_id);


--
-- Name: idx_dues_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dues_family ON public.dues_payments USING btree (pembayar_family_id);


--
-- Name: idx_dues_rt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dues_rt ON public.dues_payments USING btree (pembayar_rt_id);


--
-- Name: idx_facility_reservations_facility; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_facility_reservations_facility ON public.facility_reservations USING btree (facility_id);


--
-- Name: idx_families_rt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_families_rt ON public.families USING btree (rt_id);


--
-- Name: idx_family_rt_history_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_rt_history_family ON public.family_rt_history USING btree (family_id);


--
-- Name: idx_invitations_rt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invitations_rt ON public.invitations USING btree (rt_id);


--
-- Name: idx_invitations_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invitations_token ON public.invitations USING btree (token);


--
-- Name: idx_letters_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_letters_family ON public.letters USING btree (family_id);


--
-- Name: idx_residents_family; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_residents_family ON public.residents USING btree (family_id);


--
-- Name: idx_residents_nik; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_residents_nik ON public.residents USING btree (nik);


--
-- Name: idx_users_rt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_rt ON public.users USING btree (rt_id);


--
-- Name: idx_users_rw; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_rw ON public.users USING btree (rw_id);


--
-- Name: complaints update_complaints_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_complaints_updated_at BEFORE UPDATE ON public.complaints FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: facility_reservations update_facility_reservations_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_facility_reservations_updated_at BEFORE UPDATE ON public.facility_reservations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: letters update_letters_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_letters_updated_at BEFORE UPDATE ON public.letters FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcements announcements_pembuat_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pembuat_user_id_fkey FOREIGN KEY (pembuat_user_id) REFERENCES public.users(id);


--
-- Name: announcements announcements_target_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_target_rt_id_fkey FOREIGN KEY (target_rt_id) REFERENCES public.rts(id);


--
-- Name: cctvs cctvs_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cctvs
    ADD CONSTRAINT cctvs_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id) ON DELETE CASCADE;


--
-- Name: complaints complaints_pelapor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pelapor_user_id_fkey FOREIGN KEY (pelapor_user_id) REFERENCES public.users(id);


--
-- Name: complaints complaints_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id);


--
-- Name: documents documents_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: dues_bills dues_bills_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_bills
    ADD CONSTRAINT dues_bills_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: dues_payments dues_payments_pembayar_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_payments
    ADD CONSTRAINT dues_payments_pembayar_family_id_fkey FOREIGN KEY (pembayar_family_id) REFERENCES public.families(id);


--
-- Name: dues_payments dues_payments_pembayar_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_payments
    ADD CONSTRAINT dues_payments_pembayar_rt_id_fkey FOREIGN KEY (pembayar_rt_id) REFERENCES public.rts(id);


--
-- Name: dues_settings dues_settings_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_settings
    ADD CONSTRAINT dues_settings_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id) ON DELETE CASCADE;


--
-- Name: dues_settings dues_settings_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues_settings
    ADD CONSTRAINT dues_settings_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.rws(id) ON DELETE CASCADE;


--
-- Name: facilities facilities_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id) ON DELETE CASCADE;


--
-- Name: facility_reservations facility_reservations_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_reservations
    ADD CONSTRAINT facility_reservations_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON DELETE CASCADE;


--
-- Name: facility_reservations facility_reservations_peminjam_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_reservations
    ADD CONSTRAINT facility_reservations_peminjam_user_id_fkey FOREIGN KEY (peminjam_user_id) REFERENCES public.users(id);


--
-- Name: families families_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id);


--
-- Name: families families_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: family_rt_history family_rt_history_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family_rt_history
    ADD CONSTRAINT family_rt_history_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: family_rt_history family_rt_history_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family_rt_history
    ADD CONSTRAINT family_rt_history_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id);


--
-- Name: finances finances_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id);


--
-- Name: finances finances_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.rws(id);


--
-- Name: invitations invitations_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.rws(id) ON DELETE CASCADE;


--
-- Name: letters letters_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: residents residents_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: rts rts_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rts
    ADD CONSTRAINT rts_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.rws(id) ON DELETE CASCADE;


--
-- Name: users users_rt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_rt_id_fkey FOREIGN KEY (rt_id) REFERENCES public.rts(id) ON DELETE SET NULL;


--
-- Name: users users_rw_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_rw_id_fkey FOREIGN KEY (rw_id) REFERENCES public.rws(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict 09hdi3124h8eLQVn4o0celTtGv7whC1anYMSEUJqIhPEA2IP7ikCvnReMEr0wwF

