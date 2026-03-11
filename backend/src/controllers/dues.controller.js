const dueService = require('../services/due.service');
const { successResponse, createdResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');
const familyRepository = require('../repositories/family.repository'); // needed for fetching family_id of warga

const duesController = {
  // --- Settings ---
  async getSettings(req, res, next) {
    try {
      const { tingkat } = req.query;
      let settings;
      if (tingkat === 'WARGA' && req.user.rt_id) {
          settings = await dueService.getSettingsByRT(req.user.rt_id);
      } else if (tingkat === 'RT' && req.user.rw_id) {
          settings = await dueService.getSettingsByRW(req.user.rw_id);
      } else {
         return validationErrorResponse(res, 'Tingkat atau Role tidak sesuai');
      }
      return successResponse(res, 'Pengaturan Iuran', settings);
    } catch (error) {
      if (error.message.includes('diperlukan')) return validationErrorResponse(res, error.message);
      next(error);
    }
  },

  async createSetting(req, res, next) {
    try {
      const { tingkat, nominal, tenggat_tanggal } = req.body;
      let rt_id = null;
      let rw_id = null;

      if (tingkat === 'WARGA') rt_id = req.user.rt_id; // RT menset iuran warga
      if (tingkat === 'RT') rw_id = req.user.rw_id;    // RW menset iuran RT

      const setting = await dueService.createSetting({ tingkat, rt_id, rw_id, nominal, tenggat_tanggal });
      return createdResponse(res, 'Pengaturan iuran berhasil disimpan', setting);
    } catch (error) {
       if (error.message.includes('tidak lengkap') || error.message.includes('diperlukan')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  // --- Bills ---
  async createBill(req, res, next) {
    try {
      const { family_id, bulan, tahun, nominal } = req.body;
      const bill = await dueService.createBill({ family_id, bulan, tahun, nominal });
      return createdResponse(res, 'Tagihan berhasil dibuat', bill);
    } catch (error) {
      if (error.message.includes('не lengkap') || error.message.includes('sudah ada')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async getBillsByRT(req, res, next) {
    try {
      const { page = 1, limit = 10 } = req.query;
      const rt_id = req.user.rt_id;
      const result = await dueService.getBillsByRT(rt_id, page, limit);

      return successResponse(res, 'Daftar Tagihan', {
        bills: result.data,
        pagination: getPaginationMeta(result.total, page, limit),
      });
    } catch (error) {
      next(error);
    }
  },

  // --- Payments ---
  async createPayment(req, res, next) {
    try {
      const { bulan, tahun, nominal, metode_bayar, bukti_bayar_url } = req.body;
      
      let pembayar_family_id = null;
      let pembayar_rt_id = null;

      // Identify who is paying
      const family = await familyRepository.findByUserId(req.user.id);
      if (family) {
          pembayar_family_id = family.id;
      } else if (req.user.role === 'RT') {
          pembayar_rt_id = req.user.rt_id;
      } else {
        return validationErrorResponse(res, 'Akses ditolak: User bukan kepala keluarga');
      }

      const payment = await dueService.createPayment({ 
        pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, 
        metode_bayar, bukti_bayar_url 
      });

      return createdResponse(res, 'Pembayaran berhasil disubmit', payment);
    } catch (error) {
      if (error.message.includes('tidak lengkap')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async getPaymentsByRT(req, res, next) {
    try {
      const { page = 1, limit = 10 } = req.query;
      const rt_id = req.user.rt_id;
      const result = await dueService.getPaymentsByRT(rt_id, page, limit);

      return successResponse(res, 'Daftar Pembayaran', {
        payments: result.data,
        pagination: getPaginationMeta(result.total, page, limit),
      });
    } catch (error) {
      next(error);
    }
  },

  async verifyPayment(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const payment = await dueService.verifyPayment(id, status);
      return successResponse(res, `Pembayaran berhasil di${status === 'APPROVED' ? 'setuju' : 'tolak'}`, payment);
    } catch (error) {
      if (error.message.includes('tidak valid')) return validationErrorResponse(res, error.message);
      if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
      next(error);
    }
  }
};

module.exports = duesController;
