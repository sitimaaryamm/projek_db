
-- Migration: 001_create_schema.sql
-- Proyek IPSI: KRS Mahasiswa
-- PostgreSQL
-- Jalankan pada database kosong dengan schema public.
-- migrate:up
-- Membuat sembilan tabel database KRS Mahasiswa

CREATE TABLE prodi (
    kode_prodi VARCHAR(10) PRIMARY KEY,
    nama_prodi VARCHAR(100) NOT NULL UNIQUE,
    jenjang VARCHAR(3)
);

CREATE TABLE aturan_akademik (
    kode VARCHAR(30) PRIMARY KEY,
    nilai INT NOT NULL,
    keterangan VARCHAR(200)
);

CREATE TABLE dosen (
    id_dosen INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nidn VARCHAR(10) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    kode_prodi VARCHAR(10) NOT NULL,
    CONSTRAINT fk_dosen_prodi
        FOREIGN KEY (kode_prodi) REFERENCES prodi(kode_prodi)
);

CREATE TABLE periode (
    id_periode VARCHAR(5) PRIMARY KEY,
    nama_periode VARCHAR(30) NOT NULL,
    tgl_mulai DATE NOT NULL,
    tgl_selesai DATE NOT NULL,
    CONSTRAINT ck_periode_tanggal
        CHECK (tgl_selesai >= tgl_mulai)
);

CREATE TABLE mata_kuliah (
    kode_mk VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(100) NOT NULL,
    sks SMALLINT NOT NULL,
    semester_ke SMALLINT NOT NULL,
    CONSTRAINT ck_mk_sks CHECK (sks BETWEEN 1 AND 6),
    CONSTRAINT ck_mk_semester CHECK (semester_ke BETWEEN 1 AND 14)
);

CREATE TABLE mahasiswa (
    nim VARCHAR(12) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    tahun_masuk SMALLINT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'aktif',
    kode_prodi VARCHAR(10) NOT NULL,
    id_dosen_pa INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    no_hp VARCHAR(20),
    CONSTRAINT fk_mahasiswa_prodi
        FOREIGN KEY (kode_prodi) REFERENCES prodi(kode_prodi),
    CONSTRAINT fk_mahasiswa_dosen
        FOREIGN KEY (id_dosen_pa) REFERENCES dosen(id_dosen),
    CONSTRAINT ck_mahasiswa_tahun
        CHECK (tahun_masuk BETWEEN 2000 AND 2100),
    CONSTRAINT ck_mahasiswa_status
        CHECK (status IN ('aktif', 'cuti', 'lulus', 'nonaktif'))
);

CREATE TABLE kelas (
    id_kelas INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kode_mk VARCHAR(10) NOT NULL,
    id_periode VARCHAR(5) NOT NULL,
    id_dosen INT NOT NULL,
    nama_kelas VARCHAR(5) NOT NULL,
    kuota SMALLINT NOT NULL,
    CONSTRAINT fk_kelas_mk
        FOREIGN KEY (kode_mk) REFERENCES mata_kuliah(kode_mk),
    CONSTRAINT fk_kelas_periode
        FOREIGN KEY (id_periode) REFERENCES periode(id_periode),
    CONSTRAINT fk_kelas_dosen
        FOREIGN KEY (id_dosen) REFERENCES dosen(id_dosen),
    CONSTRAINT ck_kelas_kuota CHECK (kuota > 0)
);

CREATE TABLE krs (
    id_krs INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nim VARCHAR(12) NOT NULL,
    id_periode VARCHAR(5) NOT NULL,
    tgl_isi DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(10) NOT NULL DEFAULT 'draft',
    CONSTRAINT fk_krs_mahasiswa
        FOREIGN KEY (nim) REFERENCES mahasiswa(nim),
    CONSTRAINT fk_krs_periode
        FOREIGN KEY (id_periode) REFERENCES periode(id_periode),
    CONSTRAINT uq_krs_mahasiswa_periode UNIQUE (nim, id_periode),
    CONSTRAINT ck_krs_status
        CHECK (status IN ('draft', 'diajukan', 'disetujui'))
);

CREATE TABLE krs_detail (
    id_krs INT NOT NULL,
    id_kelas INT NOT NULL,
    nilai_huruf VARCHAR(2),
    CONSTRAINT pk_krs_detail PRIMARY KEY (id_krs, id_kelas),
    CONSTRAINT fk_detail_krs
        FOREIGN KEY (id_krs) REFERENCES krs(id_krs),
    CONSTRAINT fk_detail_kelas
        FOREIGN KEY (id_kelas) REFERENCES kelas(id_kelas),
    CONSTRAINT ck_detail_nilai
        CHECK (
            nilai_huruf IS NULL OR
            nilai_huruf IN ('A', 'B', 'C', 'D', 'E',
                            'AB', 'BC', 'CD', 'DE')
        )
);

-- migrate:down
DROP TABLE IF EXISTS krs_detail;
DROP TABLE IF EXISTS krs;
DROP TABLE IF EXISTS kelas;
DROP TABLE IF EXISTS mahasiswa;
DROP TABLE IF EXISTS mata_kuliah;
DROP TABLE IF EXISTS periode;
DROP TABLE IF EXISTS dosen;
DROP TABLE IF EXISTS aturan_akademik;
DROP TABLE IF EXISTS prodi;