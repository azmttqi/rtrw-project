const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Warga (Resident)', () => {
  let rtToken;
  let testData;

  beforeEach(async () => {
    // 1. Siapkan data pondasi (RW, RT, KK) di database
    testData = await seedBaseData();

    // 2. Login sebagai RT untuk mendapatkan Token
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        no_wa: '081200000001',
        password: 'password123'
      });
    
    rtToken = loginRes.body.data.token;
  });

  it('1. RT Berhasil Menambahkan Warga Baru ke dalam KK yang sudah ada (201)', async () => {
    const newResident = {
      nama_lengkap: 'Anak E2E',
      nik: '3200000000000001',
      jenis_kelamin: 'LAKI_LAKI',
      tempat_lahir: 'Jakarta',
      tanggal_lahir: '2010-01-01',
      agama: 'Islam',
      pendidikan: 'SD',
      jenis_pekerjaan: 'Pelajar',
      status_pernikahan: 'BELUM_KAWIN',
      hubungan_keluarga: 'Anak',
      kewarganegaraan: 'WNI',
      family_id: testData.familyId, // Menggunakan KK dari seeder
      rt_id: testData.rtId,
      rw_id: testData.rwId
    };

    // Eksekusi penambahan warga
    const res = await request(app)
      .post('/api/residents')
      .set('Authorization', `Bearer ${rtToken}`)
      .send(newResident);


    
    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.nama_lengkap).toBe(newResident.nama_lengkap);
    expect(res.body.data.nik).toBe(newResident.nik);

    // Verifikasi data masuk ke database dengan melakukan GET
    const getRes = await request(app)
      .get(`/api/residents?family_id=${testData.familyId}`)
      .set('Authorization', `Bearer ${rtToken}`);
    
    expect(getRes.status).toBe(200);
    // Mencari warga baru di dalam daftar anggota KK
    const foundResident = getRes.body.data.find(r => r.nik === newResident.nik);
    expect(foundResident).toBeDefined();
    expect(foundResident.nama_lengkap).toBe(newResident.nama_lengkap);
  });
});
