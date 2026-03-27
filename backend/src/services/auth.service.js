const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const pool = require('../config/database');
const { JWT_SECRET, JWT_EXPIRES_IN } = require('../config/jwt');
const userRepository = require('../repositories/user.repository');
const familyRepository = require('../repositories/family.repository');
const invitationRepository = require('../repositories/invitation.repository');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const authService = {
  async register({ nama, no_wa, email = null, password, role = 'RT', token_invitation, nomor_rw, alamat, nama_wilayah }) {
    // Check if user already exists by NoWa or Email
    const existingUser = await userRepository.findByNoWa(no_wa);
    if (existingUser) throw new Error('Nomor WhatsApp already registered');

    if (email) {
      const existingEmail = await userRepository.findByEmail(email);
      if (existingEmail) throw new Error('Email already registered');
    }

    let rt_id = null;
    let rw_id = null;
    let finalRole = role;

    if (role === 'RW' && !token_invitation) {
      if (!nomor_rw) throw new Error('Nomor RW wajib diisi untuk pendaftaran RW');
      const rwRes = await pool.query(
        'INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ($1, $2, $3) RETURNING id',
        [nomor_rw, nama_wilayah, alamat]
      );
      rw_id = rwRes.rows[0].id;
    }

    if (token_invitation) {
      const invitation = await invitationRepository.findByToken(token_invitation);
      if (!invitation || invitation.is_used || new Date() > invitation.expires_at) {
        throw new Error('Invalid or expired invitation token');
      }

      // Enforce WA match for Warga if specified in invitation
      if (invitation.rt_id && invitation.no_wa && invitation.no_wa !== no_wa) {
        throw new Error('Nomor WhatsApp tidak sesuai dengan undangan');
      }

      rt_id = invitation.rt_id;
      rw_id = invitation.rw_id;
      finalRole = rt_id ? 'WARGA' : 'RT';
      await invitationRepository.markAsUsed(token_invitation);
    }

    const password_hash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({
      nama, 
      no_wa, 
      email, 
      password_hash, 
      role: finalRole, 
      rt_id, 
      rw_id,
      is_verified: finalRole === 'RW' ? false : (finalRole === 'WARGA' ? false : true) // RW needs email verification
    });

    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    return { user, token };
  },

  async registerGoogle({ idToken, token_invitation }) {
    // Verify Google Token
    let google_id, email, nama;
    
    if (idToken.startsWith('mock_')) {
      // Mock validation for development
      if (idToken === 'mock_rt') {
        email = 'azmttqi@gmail.com';
        google_id = 'google_id_rt_mock';
        nama = 'Bapak RT Andi';
      } else {
        // Default mock_rw
        email = 'azmiittaqi03@gmail.com'; 
        google_id = 'google_id_rw_mock';
        nama = 'Bapak RW Iwan';
      }
    } else {
      const ticket = await client.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      const payload = ticket.getPayload();
      google_id = payload.sub;
      email = payload.email;
      nama = payload.name;
    }

    // Check if user already exists
    let user = await userRepository.findByGoogleId(google_id);
    if (!user) {
      user = await userRepository.findByEmail(email);
    }

    if (user) {
      // Login existing user
      const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
      return { user, token };
    }

    // Register new user
    let rt_id = null;
    let rw_id = null;
    let role = 'RW'; // Default for Google Registration (Autonomous RW)

    if (token_invitation) {
      const invitation = await invitationRepository.findByToken(token_invitation);
      if (!invitation || invitation.is_used || new Date() > invitation.expires_at) {
        throw new Error('Invalid or expired invitation token');
      }
      rt_id = invitation.rt_id;
      rw_id = invitation.rw_id;
      role = rt_id ? 'WARGA' : 'RT';
      await invitationRepository.markAsUsed(token_invitation);
    }

    user = await userRepository.create({
      nama, email, google_id, role, rt_id, rw_id
    });

    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    return { user, token };
  },

  async login({ no_wa, password }) {
    // no_wa here can be email or wa
    const user = await userRepository.findByIdentifier(no_wa);
    if (!user) {
      throw new Error('Invalid credentials');
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      throw new Error('Invalid credentials');
    }

    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN,
    });

    return { user, token };
  },

  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  },

  async updateProfile(userId, { nama }) {
    const user = await userRepository.update(userId, { nama });
    return user;
  },

  async verifyEmail({ identifier, otp }) {
    // Mock OTP verification logic
    // In production, we'd check against a redis/db stored OTP
    if (otp !== '123456') {
      throw new Error('Kode verifikasi tidak valid atau kedaluwarsa');
    }

    const user = await userRepository.findByIdentifier(identifier);
    if (!user) throw new Error('Pengguna tidak ditemukan');

    const updatedUser = await userRepository.update(user.id, { is_verified: true });
    return updatedUser;
  },
};

module.exports = authService;

