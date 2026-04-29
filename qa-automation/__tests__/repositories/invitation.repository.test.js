const invitationRepository = require('../../../backend/src/repositories/invitation.repository');
const pool = require('../../../backend/src/config/database');

describe('Invitation Repository', () => {
  let rtId, rwId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;
  });

  describe('create', () => {
    it('Success: membuat undangan baru', async () => {
      const invitation = await invitationRepository.create({
        no_wa: '08123456786',
        rt_id: rtId
      });

      expect(invitation).toBeDefined();
      expect(invitation.no_wa).toBe('08123456786');
      expect(invitation.rt_id).toBe(rtId);
      expect(invitation.token).toBeDefined();
      expect(invitation.is_used).toBe(false);
    });
  });

  describe('findByToken', () => {
    it('Success: menemukan undangan berdasarkan token', async () => {
      const created = await invitationRepository.create({
        no_wa: '08123456787',
        rt_id: rtId
      });

      const found = await invitationRepository.findByToken(created.token);
      expect(found).toBeDefined();
      expect(found.id).toBe(created.id);
    });
  });

  describe('markAsUsed', () => {
    it('Success: menandai undangan sebagai terpakai', async () => {
      const created = await invitationRepository.create({
        no_wa: '08123456788',
        rt_id: rtId
      });

      const updated = await invitationRepository.markAsUsed(created.token);
      expect(updated.is_read).toBeUndefined(); // Verify field name, invitations has is_used
      expect(updated.is_used).toBe(true);
    });
  });
});
