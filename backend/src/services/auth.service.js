const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { JWT_SECRET, JWT_EXPIRES_IN } = require('../config/jwt');
const userRepository = require('../repositories/user.repository');
const familyRepository = require('../repositories/family.repository');
const invitationRepository = require('../repositories/invitation.repository');

const authService = {
  async register({ nama, no_wa, password, token_invitation }) {
    // Check if user already exists
    const existingUser = await userRepository.findByNoWa(no_wa);
    if (existingUser) {
      throw new Error('Nomor WhatsApp already registered');
    }

    // Validate invitation token if provided
    let rt_id = null;
    if (token_invitation) {
      const invitation = await invitationRepository.findByToken(token_invitation);
      if (!invitation) {
        throw new Error('Invalid invitation token');
      }
      if (invitation.is_used) {
        throw new Error('Invitation token already used');
      }
      if (new Date() > invitation.expires_at) {
        throw new Error('Invitation token expired');
      }
      rt_id = invitation.rt_id;

      // Mark invitation as used
      await invitationRepository.markAsUsed(token_invitation);
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Create user
    const role = rt_id ? 'WARGA' : 'RT';
    const user = await userRepository.create({
      nama,
      no_wa,
      password_hash,
      role,
      rt_id,
      rw_id: null,
    });

    // Generate JWT token
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN,
    });

    return { user, token };
  },

  async login({ no_wa, password }) {
    const user = await userRepository.findByNoWa(no_wa);
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
};

module.exports = authService;

