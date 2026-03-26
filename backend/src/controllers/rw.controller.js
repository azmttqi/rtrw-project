const pool = require('../config/database');
const { successResponse, createdResponse, errorResponse } = require('../utils/response');

const rwController = {
  async setupEnvironment(req, res, next) {
    const client = await pool.connect();
    try {
      const { nomor_rw, rts } = req.body; // rts: list of strings (rt numbers)
      const userId = req.user.id;

      if (!nomor_rw || !rts || !Array.isArray(rts)) {
        return errorResponse(res, 'Nomor RW dan daftar RT wajib diisi', 400);
      }

      await client.query('BEGIN');

      // 1. Create/Find RW
      const rwResult = await client.query(
        'INSERT INTO rws (nomor_rw) VALUES ($1) ON CONFLICT (nomor_rw) DO UPDATE SET nomor_rw = EXCLUDED.nomor_rw RETURNING id',
        [nomor_rw]
      );
      const rwId = rwResult.rows[0].id;

      // 2. Link user to RW
      await client.query(
        'UPDATE users SET rw_id = $1 WHERE id = $2',
        [rwId, userId]
      );

      // 3. Create RTs
      const createdRts = [];
      for (const nomor_rt of rts) {
        const rtResult = await client.query(
          'INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, $2) ON CONFLICT (rw_id, nomor_rt) DO UPDATE SET nomor_rt = EXCLUDED.nomor_rt RETURNING *',
          [rwId, nomor_rt]
        );
        createdRts.push(rtResult.rows[0]);
      }

      await client.query('COMMIT');

      return createdResponse(res, 'Lingkungan RW berhasil disetup', {
        rwId,
        nomor_rw,
        rts: createdRts
      });
    } catch (error) {
      await client.query('ROLLBACK');
      next(error);
    } finally {
      client.release();
    }
  }
};

module.exports = rwController;
