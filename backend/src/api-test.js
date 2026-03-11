const http = require('http');

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
      res.on('end', () => resolve(JSON.parse(responseBody)));
    });
    
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  try {
    // 1. Login to get token for Warga Role
    const loginWarga = await request('/api/auth/login', 'POST', { no_wa: '081234567890', password: 'rahasia123' });
    const tokenWarga = loginWarga.data.token;
    console.log('[1] Token Warga retrieved.');

    // 2. Create Family
    const createFam = await request('/api/families', 'POST', {
      rt_id: 1, no_kk: '3215000000000001', tipe_warga: 'LAMA', status_tinggal: 'TETAP', status_pernikahan: 'KAWIN'
    }, tokenWarga);
    console.log('[2] Create Family Response:', createFam.message);
    const familyId = createFam.data.id;

    // 3. Add Resident
    const addRes = await request('/api/residents', 'POST', {
      family_id: familyId, nik: '3215000000000002', nama_lengkap: 'Istri Budi', 
      jenis_kelamin: 'PEREMPUAN', tanggal_lahir: '1995-10-10', hubungan_keluarga: 'ISTRI'
    }, tokenWarga);
    console.log('[3] Add Resident Response:', addRes.message);

    // 4. Login to get token for RT Role
    const loginRt = await request('/api/auth/login', 'POST', { no_wa: '089999999999', password: 'rahasia123' });
    const tokenRt = loginRt.data.token;
    console.log('[4] Token RT retrieved.');

    // 5. Verify Family as RT
    const verifyFam = await request(`/api/families/${familyId}/verify`, 'PATCH', { status: 'APPROVED' }, tokenRt);
    console.log('[5] Verify Family Response:', verifyFam.message);
    
  } catch (err) {
    console.error('Test Failed:', err);
  }
}

runTests();
