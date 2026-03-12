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
    // Register Warga A
    await request('/api/auth/register', 'POST', {
        nama: 'Asep',
        no_wa: '081234567890',
        password: 'rahasia123',
        role: 'WARGA'
    });
    
    // Register Warga B
    await request('/api/auth/register', 'POST', {
        nama: 'Warga B',
        no_wa: '081298765432',
        password: 'rahasia123',
        role: 'WARGA'
    });

    console.log("Users registered.");

  } catch (err) {
    console.error('Test Failed:', err);
  }
}

runTests();
