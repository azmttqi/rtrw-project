const duesRepository = require('../repositories/dues.repository');
const notificationService = require('./notification.service');
const familyRepository = require('../repositories/family.repository');

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

    const bill = await duesRepository.createBill({ family_id, bulan, tahun, nominal });

    // Kirim Notifikasi Internal & WA
    const family = await familyRepository.findById(family_id);
    if (family) {
      await notificationService.notifyUser(family.user_id, {
        title: 'Tagihan Iuran Baru',
        message: `Tagihan iuran untuk periode ${bulan}/${tahun} sebesar Rp ${nominal} telah diterbitkan.`,
        sendWA: true
      });
    }

    return bill;
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
        
        // Notifikasi ke warga
        const family = await familyRepository.findById(payment.pembayar_family_id);
        if (family) {
          await notificationService.notifyUser(family.user_id, {
            title: 'Pembayaran Iuran Disetujui',
            message: `Pembayaran iuran periode ${payment.bulan}/${payment.tahun} telah diverifikasi dan disetujui. Terima kasih.`,
            sendWA: true
          });
        }
    } else if (status === 'REJECTED' && payment.pembayar_family_id) {
        // Notifikasi penolakan
        const family = await familyRepository.findById(payment.pembayar_family_id);
        if (family) {
          await notificationService.notifyUser(family.user_id, {
            title: 'Pembayaran Iuran Ditolak',
            message: `Pembayaran iuran periode ${payment.bulan}/${payment.tahun} ditolak oleh pengurus. Silakan cek kembali bukti bayar Anda atau hubungi RT.`,
            sendWA: true
          });
        }
    }

    return updatedPayment;
  },

  /**
   * Mengirimkan pengingat manual melalui WhatsApp
   */
  async sendManualReminder(billId) {
    const bill = await duesRepository.findBillById(billId);
    if (!bill) throw new Error('Tagihan tidak ditemukan');
    if (bill.status === 'APPROVED') throw new Error('Tagihan sudah lunas');

    const family = await familyRepository.findById(bill.family_id);
    if (!family) throw new Error('Data keluarga tidak ditemukan');

    const whatsappService = require('./whatsapp.service');
    return await whatsappService.sendDueReminder(family.no_wa, {
        nama: family.nama,
        jenis: 'Iuran Warga Bulanan',
        nominal: bill.nominal,
        bulan: bill.bulan,
        tahun: bill.tahun
    });
  }
};

module.exports = dueService;
