const authService = require('../../../backend/src/services/auth.service');
const userRepository = require('../../../backend/src/repositories/user.repository');
const invitationRepository = require('../../../backend/src/repositories/invitation.repository');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

jest.mock('../../../backend/src/repositories/user.repository');
jest.mock('../../../backend/src/repositories/invitation.repository');
jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

describe('Auth Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('login', () => {
    it('Success: login berhasil', async () => {
      userRepository.findByIdentifier.mockResolvedValue({ id: 1, role: 'RT', password_hash: 'hash' });
      bcrypt.compare.mockResolvedValue(true);
      jwt.sign.mockReturnValue('mock-token');

      const result = await authService.login({ no_wa: '0811', password: 'password' });
      expect(result.token).toBe('mock-token');
      expect(result.user.id).toBe(1);
    });

    it('Negative: user tidak ditemukan', async () => {
      userRepository.findByIdentifier.mockResolvedValue(null);
      await expect(authService.login({ no_wa: '0811', password: 'password' })).rejects.toThrow('Invalid credentials');
    });

    it('Negative: password salah', async () => {
      userRepository.findByIdentifier.mockResolvedValue({ id: 1, role: 'RT', password_hash: 'hash' });
      bcrypt.compare.mockResolvedValue(false);
      await expect(authService.login({ no_wa: '0811', password: 'password' })).rejects.toThrow('Invalid credentials');
    });
  });

  describe('register', () => {
    const payload = { nama: 'Budi', no_wa: '081234567890', password: 'password123', role: 'WARGA', token_invitation: 'token' };


    it('Success: register WARGA dengan token valid', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      invitationRepository.findByToken.mockResolvedValue({ is_used: false, expires_at: new Date(Date.now() + 10000), rt_id: 'rt-1' });
      bcrypt.hash.mockResolvedValue('hash');
      userRepository.create.mockResolvedValue({ id: 1, role: 'WARGA' });
      jwt.sign.mockReturnValue('mock-token');

      const result = await authService.register(payload);
      expect(result.token).toBe('mock-token');
    });

    it('Negative: WA sudah terdaftar', async () => {
      userRepository.findByNoWa.mockResolvedValue({ id: 1 });
      await expect(authService.register(payload)).rejects.toThrow('already registered');
    });

    it('Negative: token undangan expired/invalid', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      invitationRepository.findByToken.mockResolvedValue(null);
      await expect(authService.register(payload)).rejects.toThrow('Invalid or expired');
    });

    it('Boundary: password terlalu pendek (min 6)', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      const shortPassPayload = { ...payload, password: '123' };
      try {
        await authService.register(shortPassPayload);
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Password minimal 6 karakter');
      }
    });

    it('Boundary: nomor WA terlalu pendek', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      const shortWaPayload = { ...payload, no_wa: '0812', password: 'password123' };
      try {
        await authService.register(shortWaPayload);
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Nomor WhatsApp tidak valid');
      }
    });

    it('Negative: email format tidak valid', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      const badEmailPayload = { ...payload, no_wa: '08123456789', email: 'bukan-email', password: 'password123' };
      try {
        await authService.register(badEmailPayload);
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Format email tidak valid');
      }
    });

    it('Negative: role tidak dikenal', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      const badRolePayload = { ...payload, no_wa: '08123456789', role: 'HACKER', password: 'password123' };
      try {
        await authService.register(badRolePayload);
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Role tidak valid');
      }
    });
  });
});
