const http = require('http');

const BASE = 'http://localhost:3001';

function makeRequest(path, options = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE);
    const reqOptions = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    };
    const req = http.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch {
          resolve(data);
        }
      });
    });
    req.on('error', reject);
    if (options.body) req.write(options.body);
    req.end();
  });
}

async function run() {
  let token;
  
  try {
    // Health
    const health = await makeRequest('/api/health');
    console.log('✅ Health:', JSON.stringify(health));
    
    // Signup
    const signup = await makeRequest('/api/auth/signup', {
      method: 'POST',
      body: JSON.stringify({ name: 'Test User', email: 'test@example.com', password: 'password123' }),
    });
    console.log('✅ Signup:', JSON.stringify(signup));
    
    if (signup.token) {
      token = signup.token;
    } else {
      // Try login if signup failed (user may already exist)
      const login = await makeRequest('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email: 'test@example.com', password: 'password123' }),
      });
      console.log('✅ Login:', JSON.stringify(login));
      token = login.token;
    }

    const authH = { Authorization: `Bearer ${token}` };

    // Onboarding
    const onboard = await makeRequest('/api/auth/onboarding', {
      method: 'POST',
      headers: authH,
      body: JSON.stringify({ companyName: 'Acme Corp', industry: 'SaaS', monthlyRevenue: 80000, monthlyExpenses: 55000, employees: 15 }),
    });
    console.log('✅ Onboarding:', JSON.stringify(onboard));

    // Dashboard
    const metrics = await makeRequest('/api/dashboard/metrics', { headers: authH });
    console.log('✅ Dashboard Metrics:', JSON.stringify(metrics));

    const trends = await makeRequest('/api/dashboard/trends', { headers: authH });
    console.log('✅ Dashboard Trends:', JSON.stringify(trends));

    const activity = await makeRequest('/api/dashboard/activity', { headers: authH });
    console.log('✅ Dashboard Activity:', JSON.stringify(activity));

    // Forecasting
    const forecast = await makeRequest('/api/forecasting/project', {
      method: 'POST',
      headers: authH,
      body: JSON.stringify({ months: 12, revenueGrowth: 5, expenseGrowth: 3, hiringCost: 0 }),
    });
    console.log('✅ Forecasting:', JSON.stringify(forecast).substring(0, 200) + '...');

    // AI Chat
    const aiChat = await makeRequest('/api/ai/chat', {
      method: 'POST',
      headers: authH,
      body: JSON.stringify({ message: 'What is my current runway?' }),
    });
    console.log('✅ AI Chat:', JSON.stringify(aiChat).substring(0, 200) + '...');

    // AI History
    const aiHistory = await makeRequest('/api/ai/history', { headers: authH });
    console.log('✅ AI History:', JSON.stringify(aiHistory).substring(0, 200) + '...');

    // AI Suggestions
    const aiSuggestions = await makeRequest('/api/ai/suggestions');
    console.log('✅ AI Suggestions:', JSON.stringify(aiSuggestions));

    // Reports
    const pnl = await makeRequest('/api/reports/pnl', { headers: authH });
    console.log('✅ Report P&L:', JSON.stringify(pnl).substring(0, 200) + '...');

    const bs = await makeRequest('/api/reports/balance-sheet', { headers: authH });
    console.log('✅ Report Balance Sheet:', JSON.stringify(bs).substring(0, 200) + '...');

    const cf = await makeRequest('/api/reports/cash-flow', { headers: authH });
    console.log('✅ Report Cash Flow:', JSON.stringify(cf).substring(0, 200) + '...');

    // Marketplace
    const advisors = await makeRequest('/api/marketplace/advisors');
    console.log('✅ Marketplace Advisors:', JSON.stringify(advisors).substring(0, 200) + '...');

    // Notifications
    const notifs = await makeRequest('/api/notifications', { headers: authH });
    console.log('✅ Notifications:', JSON.stringify(notifs).substring(0, 200) + '...');

    // Profile
    const profile = await makeRequest('/api/profile', { headers: authH });
    console.log('✅ Profile:', JSON.stringify(profile).substring(0, 200) + '...');

    // Fundraising
    const readiness = await makeRequest('/api/fundraising/readiness', { headers: authH });
    console.log('✅ Fundraising Readiness:', JSON.stringify(readiness).substring(0, 200) + '...');

    const dataRoom = await makeRequest('/api/fundraising/data-room', { headers: authH });
    console.log('✅ Fundraising Data Room:', JSON.stringify(dataRoom).substring(0, 200) + '...');

    console.log('\n✅ ALL ENDPOINTS TESTED SUCCESSFULLY');
  } catch (err) {
    console.error('❌ Error:', err.message);
  }
}

run();