const duesRepository = require('../repositories/dues.repository');

const dueService = {
  // --- Settings ---
  async getSettingsByRT(rtId) {
    if (!rtId) throw new Error('RT ID diperlukan');
    return await duesRepository.findSettingsByRT(rtId);
  },

  async getSettingsByRW(rwId) {
     if (!rwId) throw new Error('RW ID diperlukan');
    return await duesRepository.findSettingsByRW(rwId);
  },

  async createSetting({ tingkat, rt_id, rw_id, nominal, tenggat_tanggal }) {
    if (!tingkat || !nominal || !tenggat_tanggal) {
      throw new Error('Data pengaturan iuran tidak lengkap');
    }
    if (tingkat === 'WARGA' && !rt_id) throw new Error('RT ID diperlukan untuk tingkat Warga');
    if (tingkat === 'RT' && !rw_id) throw new Error('RW ID diperlukan untuk tingkat RT');

    return await duesRepository.createSetting({ tingkat, rt_id, rw_id, nominal, tenggat_tanggal });
  },

  // --- Bills ---
  async createBill({ family_id, bulan, tahun, nominal }) {
    if (!family_id || !bulan || !tahun || !nominal) {
      throw new Error('Data tagihan tidak lengkap');
    }

    const existingBill = await duesRepository.findBillByFamilyAndPeriod(family_id, bulan, tahun);
    if (existingBill) {
      throw new Error('Tagihan untuk periode ini sudah ada');
    }

    return await duesRepository.createBill({ family_id, bulan, tahun, nominal });
  },

  async getBillsByRT(rtId, page, limit) {
    if (!rtId) throw new Error('RT ID diperlukan');
    return await duesRepository.findBillsByRT(rtId, { page: parseInt(page), limit: parseInt(limit) });
  },

  async updateBillStatus(id, status) {
    if (!['PENDING', 'APPROVED', 'REJECTED'].includes(status)) {
      throw new Error('Status tagihan tidak valid');
    }
    const bill = await duesRepository.updateBillStatus(id, status);
    if (!bill) throw new Error('Tagihan tidak ditemukan');
    return bill;
  },

  // --- Payments ---
  async createPayment({ pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, metode_bayar, bukti_bayar_url }) {
    if (!bulan || !tahun || !nominal || !metode_bayar) {
      throw new Error('Data pembayaran tidak lengkap');
    }
    
    // Asumsi: Jika pembayar_family_id ada, berarti ini iuran WARGA ke RT.
    // Jika pembayar_rt_id ada, berarti ini iuran RT ke RW.
    if (!pembayar_family_id && !pembayar_rt_id) {
       throw new Error('Identitas pembayar tidak lengkap');
    }

    return await duesRepository.createPayment({ 
      pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, 
      metode_bayar, bukti_bayar_url 
    });
  },

  async getPaymentsByRT(rtId, page, limit) {
     if (!rtId) throw new Error('RT ID diperlukan');
     return await duesRepository.findPaymentsByRT(rtId, { page: parseInt(page), limit: parseInt(limit) });
  },

  async verifyPayment(id, status) {
    if (!['APPROVED', 'REJECTED'].includes(status)) {
      throw new Error('Status verifikasi tidak valid');
    }

    const payment = await duesRepository.findPaymentById(id);
    if (!payment) throw new Error('Pembayaran tidak ditemukan');

    const updatedPayment = await duesRepository.verifyPayment(id, status);

    // Jika pembayaran disetujui dan ini adalah pembayaran Keluarga, update status tagihan
    if (status === 'APPROVED' && payment.pembayar_family_id) {
        const bill = await duesRepository.findBillByFamilyAndPeriod(
            payment.pembayar_family_id, payment.bulan, payment.tahun
        );
        if (bill) {
            await duesRepository.updateBillStatus(bill.id, 'APPROVED');
        }
    }

    return updatedPayment;
  }
};

module.exports = dueService;
