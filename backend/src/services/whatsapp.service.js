/**
 * WhatsApp Service
 * 
 * Tahap awal: Mock implementation untuk simulasi pengiriman.
 * Siap dihubungkan ke Fonnte atau provider WA API lainnya.
 */

const whatsappService = {
  /**
   * Mengirim pesan WhatsApp
   * @param {string} target - Nomor WA tujuan (format: 08xx atau 628xx)
   * @param {string} message - Isi pesan
   */
  async sendMessage(target, message) {
    try {
      // Validasi nomor tujuan
      if (!target) {
        console.warn('[WA-SERVICE] Skip sending: No target number');
        return false;
      }

      console.log(`[WA-SERVICE] SENDING TO: ${target}`);
      console.log(`[WA-SERVICE] MESSAGE: \n---\n${message}\n---`);

      // CONTOH INTEGRASI FONNTE (DIKOMENTARI)
      /*
      const response = await fetch('https://api.fonnte.com/send', {
        method: 'POST',
        headers: {
          'Authorization': process.env.FONNTE_TOKEN // Ganti dengan token yang didapat dari fonnte.com
        },
        body: new URLSearchParams({
          target: target,
          message: message,
          delay: '2',
          countryCode: '62'
        })
      });
      const result = await response.json();
      return result.status === true;
      */

      // Simulasi delay jaringan
      await new Promise(resolve => setTimeout(resolve, 500));
      
      return true;
    } catch (error) {
      console.error('[WA-SERVICE] Error sending message:', error.message);
      return false;
    }
  },

  /**
   * Mengirim pengingat iuran (Example Template)
   */
  async sendDueReminder(target, data) {
    const { nama, jenis, nominal, bulan, tahun } = data;
    const message = 
`*PENGINGAT IURAN RT/RW*

Halo Bapak/Ibu ${nama},

Kami ingin menginformasikan bahwa terdapat tagihan iuran yang perlu diselesaikan:
📌 *Jenis:* ${jenis}
📌 *Periode:* ${bulan} ${tahun}
💰 *Nominal:* Rp ${new Intl.NumberFormat('id-ID').format(nominal)}

Mohon segera melakukan pembayaran melalui aplikasi atau hubungi pengurus RT.
Abaikan jika Anda sudah membayar.

Terima kasih.
_Pesan otomatis dari Sistem RT/RW Digital_`;

    return await this.sendMessage(target, message);
  }
};

module.exports = whatsappService;
