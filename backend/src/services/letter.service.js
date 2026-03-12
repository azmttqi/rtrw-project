const letterRepository = require('../repositories/letter.repository');
const pool = require('../config/database');
const PDFDocument = require('pdfkit');
const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const letterService = {
  async createLetter(data) {
    const { family_id, jenis_surat, keterangan_keperluan } = data;
    if (!jenis_surat || !keterangan_keperluan) {
      throw new Error('Jenis surat dan keterangan keperluan wajib diisi');
    }
    return await letterRepository.createLetter(data);
  },

  async getLetters(user) {
    if (user.role === 'RT') {
      return await letterRepository.getLettersByRT(user.rt_id);
    } else if (user.role === 'RW') {
      let rw_id = user.rw_id;
      if (!rw_id) {
          const res = await pool.query('SELECT rw_id FROM rts WHERE id = $1', [user.rt_id]);
          rw_id = res.rows[0]?.rw_id;
      }
      return await letterRepository.getLettersByRW(rw_id);
    } else {
      const res = await pool.query('SELECT id FROM families WHERE user_id = $1', [user.id]);
      const family_id = res.rows[0]?.id;
      if (!family_id) return [];
      return await letterRepository.getLettersByFamily(family_id);
    }
  },

  async verifyLetter(id, user, status) {
    const letter = await letterRepository.getLetterById(id);
    if (!letter) throw new Error('Surat tidak ditemukan');

    if (user.role === 'RT') {
      if (letter.rt_id !== user.rt_id) throw new Error('Bukan wewenang RT ini');
      if (letter.status !== 'PENDING_RT') throw new Error('Status surat tidak valid untuk diverifikasi RT');

      const nextStatus = status === 'APPROVED' ? 'APPROVED_RT_PENDING_RW' : 'REJECTED_RT';
      return await letterRepository.updateLetterStatus(id, nextStatus);
    } 

    if (user.role === 'RW') {
      let rw_id = user.rw_id;
      if (!rw_id) {
          const res = await pool.query('SELECT rw_id FROM rts WHERE id = $1', [user.rt_id]);
          rw_id = res.rows[0]?.rw_id;
      }
      
      if (letter.rw_id !== rw_id) throw new Error('Bukan wewenang RW ini');
      if (letter.status !== 'APPROVED_RT_PENDING_RW') throw new Error('Harus disetujui RT terlebih dahulu');

      const nextStatus = status === 'APPROVED' ? 'APPROVED_RW' : 'REJECTED_RW';
      
      let docUrl = null;
      if (nextStatus === 'APPROVED_RW') {
        docUrl = await this.generatePDF(id);
      }
      
      return await letterRepository.updateLetterStatus(id, nextStatus, docUrl);
    }

    throw new Error('Anda tidak memiliki akses untuk verifikasi');
  },

  async generatePDF(id) {
    try {
        const letter = await letterRepository.getLetterById(id);
        if (!letter) {
            throw new Error('Cetak PDF Gagal: Data surat tidak ditemukan');
        }

        const result = await pool.query(
            `SELECT u.nama, u.no_wa, r.nik
            FROM families f 
            JOIN users u ON f.user_id = u.id 
            LEFT JOIN residents r ON r.family_id = f.id AND r.hubungan_keluarga = 'KEPALA_KELUARGA'
            WHERE f.id = $1 
            LIMIT 1`,
            [letter.family_id]
        );
        
        const pemohon = result?.rows?.[0];

        const fileName = `letter-${id}-${uuidv4()}.pdf`;
        const uploadDir = path.resolve(__dirname, '../../uploads/letters');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        
        const filePath = path.join(uploadDir, fileName);
        const doc = new PDFDocument();
        const writeStream = fs.createWriteStream(filePath);
        doc.pipe(writeStream);

        // Header
        doc.fontSize(16).text('SURAT PENGANTAR RT/RW', { align: 'center' });
        doc.fontSize(12).text(`RW ${letter.nomor_rw || '-'} / RT ${letter.nomor_rt || '-'}`, { align: 'center' });
        doc.moveDown();
        doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke();
        doc.moveDown();

        // Content
        doc.text(`Yang bertanda tangan di bawah ini, Pengurus RT ${letter.nomor_rt || '-'} RW ${letter.nomor_rw || '-'}, menerangkan bahwa:`);
        doc.moveDown(0.5);
        doc.text(`Nama : ${pemohon?.nama || '-'}`);
        doc.text(`NIK  : ${pemohon?.nik || '-'}`);
        doc.text(`No KK: ${letter.no_kk || '-'}`);
        doc.moveDown();
        doc.text(`Adalah benar warga kami yang bermaksud mengajukan:`);
        doc.font('Helvetica-Bold').text(`${letter.jenis_surat}`, { indent: 20 });
        doc.font('Helvetica').text(`Keperluan: ${letter.keterangan_keperluan}`, { indent: 20 });
        doc.moveDown();
        doc.text('Demikian surat pengantar ini dibuat untuk dipergunakan sebagaimana mestinya.');

        // QR Code for validation
        const qrData = `https://rtrw-app.com/v1/verify-letter/${id}`;
        const qrImage = await QRCode.toDataURL(qrData);
        doc.image(qrImage, 450, 600, { width: 100 });
        doc.fontSize(8).text('Scan untuk verifikasi keaslian', 450, 700);

        // Footer / Signatures
        doc.fontSize(10);
        const date = new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
        doc.text(`Karawang, ${date}`, 50, 600);
        doc.text('Ketua RT', 50, 620);
        doc.text('( DIGITAL SIGNATURE )', 50, 680);
        
        doc.text('Ketua RW', 250, 620);
        doc.text('( DIGITAL SIGNATURE )', 250, 680);

        doc.end();
        
        await new Promise((resolve, reject) => {
            writeStream.on('finish', resolve);
            writeStream.on('error', reject);
        });

        console.log('PDF Generated Successfully');
        return `/uploads/letters/${fileName}`;
    } catch (err) {
        throw err;
    }
  },

  async getLetterFile(id, user) {
      const letter = await letterRepository.getLetterById(id);
      if (!letter) throw new Error('Surat tidak ditemukan');
      // Logic checking ownership etc.
      return letter.dokumen_hasil_url;
  }
};

module.exports = letterService;
