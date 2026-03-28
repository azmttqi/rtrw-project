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
    console.log("--- Starting Dues Reminder Test ---");

    // 1. Login RT
    const loginRt = await request('/api/auth/login', 'POST', { no_wa: '089999999999', password: 'rahasia123' });
    const tokenRt = loginRt.data?.token;
    if (!tokenRt) throw new Error('Failed to get RT token');
    console.log('[1] Login RT: OK');

    // 1.5 Test Settings (Existing endpoint)
    const settingsRes = await request('/api/dues/settings?tingkat=WARGA', 'GET', null, tokenRt);
    console.log('[1.5] Settings Res:', settingsRes.message || 'SUCCESS');

    // 2. Get Bills
    const billsRes = await request('/api/dues/bills?page=1&limit=5', 'GET', null, tokenRt);
    console.log('[2] Get Bills:', billsRes.data?.bills ? 'OK' : 'FAILED');
    const bills = billsRes.data?.bills;

    // 2.5 Test Create Bill (POST)
    const newBill = await request('/api/dues/bills', 'POST', { family_id: 1, bulan: 'Testing', tahun: 2026, nominal: 1000 }, tokenRt);
    console.log('[2.5] Create Bill Res:', newBill.message);

    const pendingBill = bills?.find(b => b.status === 'PENDING');
    if (!pendingBill) {
        console.log('No PENDING bills found to test reminder.');
        return;
    }
    console.log(`[3] Found PENDING bill (ID: ${pendingBill.id})`);

    // 3. Trigger Reminder
    const remindUrl = `/api/dues/bills/${pendingBill.id}/remind`;
    console.log(`[4] Triggering POST: ${remindUrl}`);
    const remindRes = await request(remindUrl, 'POST', null, tokenRt);
    console.log('Response Message:', remindRes.message);
    console.log('Full Response:', JSON.stringify(remindRes));

    if (remindRes.success) {
        console.log('--- TEST SUCCESSFUL ---');
    } else {
        console.log('--- TEST FAILED ---');
    }

  } catch (err) {
    console.error('Test Error:', err);
  }
}

runTests();
