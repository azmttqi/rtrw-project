const request = require('supertest');
const app = require('../../../backend/src/app');
const pool = require('../../../backend/src/config/database');

describe('E2E: Auth Flow', () => {
  // Data testing yang valid sesuai dengan validasi BVA yang ketat
  const testUser = {
    nama: 'Budi E2E',
    no_wa: '081234567891', // min 10 digit
    email: 'budi.e2e@test.com',
    password: 'password123', // min 6 karakter
    role: 'RT'
  };

  it('Complete E2E Auth Flow: Register -> Duplicate Check -> Login', async () => {
    // 1. Skenario Happy Path: Register User Baru -> Berhasil (201)
    const resRegister = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(resRegister.status).toBe(201);
    expect(resRegister.body.success).toBe(true);
    expect(resRegister.body.data.user).toHaveProperty('id');
    expect(resRegister.body.data.user.nama).toBe(testUser.nama);
    expect(resRegister.body.data.user.no_wa).toBe(testUser.no_wa);

    // 2. Skenario BVA/Negative: Register dengan No WA duplikat -> Gagal (400)
    const resDuplicate = await request(app)
      .post('/api/auth/register')
      .send({
        ...testUser,
        email: 'budi.beda@test.com' // Email dibedakan, WA sama
      });

    expect(resDuplicate.status).toBe(400);
    expect(resDuplicate.body.success).toBe(false);

    // 3. Skenario Happy Path: Login dengan user yang baru dibuat -> Berhasil (200)
    const resLogin = await request(app)
      .post('/api/auth/login')
      .send({
        no_wa: testUser.no_wa,
        password: testUser.password
      });

    expect(resLogin.status).toBe(200);
    expect(resLogin.body.success).toBe(true);
    expect(resLogin.body.data).toHaveProperty('token');
    expect(resLogin.body.data.user.nama).toBe(testUser.nama);
  });
});

