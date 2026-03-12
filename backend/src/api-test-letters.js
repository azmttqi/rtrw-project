const http = require('http');
const fs = require('fs');
const path = require('path');

function request(path, method, data, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;

    const req = http.request(options, res => {
      let responseBody = '';
      res.on('data', chunk => responseBody += chunk);
      res.on('end', () => {
          try {
              resolve(JSON.parse(responseBody));
          } catch(e) {
              resolve(responseBody);
          }
      });
    });
    
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  try {
    console.log("--- Starting Letters Test ---");

    // 1. Login RT
    const loginRt = await request('/api/auth/login', 'POST', { no_wa: '089999999999', password: 'rahasia123' });
    console.log('Login RT Response:', loginRt);
    const tokenRt = loginRt.data?.token;
    if (!tokenRt) throw new Error('Failed to get RT token');
    console.log('[1] Token RT: OK');

    // 2. Login Warga
    const loginWarga = await request('/api/auth/login', 'POST', { no_wa: '081234567890', password: 'rahasia123' });
    console.log('Login Warga Response:', loginWarga);
    const tokenWarga = loginWarga.data?.token;
    if (!tokenWarga) throw new Error('Failed to get Warga token');
    console.log('[2] Token Warga: OK');

    // 3. Warga requests a letter
    const reqLetter = await request('/api/letters', 'POST', {
        jenis_surat: 'Surat Keterangan Domisili',
        keterangan_keperluan: 'Persyaratan buka rekening bank'
    }, tokenWarga);
    console.log('[3] Letter Requested:', reqLetter.message);
    const letterId = reqLetter.data?.id;

    if (letterId) {
        // 4. RT verifies (Approve)
        const verifyRt = await request(`/api/letters/${letterId}/verify`, 'PATCH', { status: 'APPROVED' }, tokenRt);
        console.log('[4] RT Verified:', verifyRt.message, 'Status:', verifyRt.data?.status);

        // 5. RW verifies (Approve)
        const loginRw = await request('/api/auth/login', 'POST', { no_wa: '087777777777', password: 'rahasia123' });
        const tokenRw = loginRw.data?.token;
        if (!tokenRw) throw new Error('Failed to get RW token');
        console.log('[5] Token RW: OK');

        const verifyRw = await request(`/api/letters/${letterId}/verify`, 'PATCH', { status: 'APPROVED' }, tokenRw);
        console.log('[6] RW Verified:', verifyRw.message, 'Status:', verifyRw.data?.status);
        console.log('    PDF URL:', verifyRw.data?.dokumen_hasil_url);

        // 7. Warga downloads PDF
        console.log('[7] Testing PDF Download Access...');
        const download = await request(`/api/letters/${letterId}/download`, 'GET', null, tokenWarga);
        if (typeof download === 'string' && download.includes('%PDF')) {
            console.log('    Download Response: SUCCESS (PDF found)');
        } else {
            console.log('    Download Response:', download.message || 'Error downloading');
        }
    }

  } catch (err) {
    console.error('Test Error:', err);
  }
}

runTests();
