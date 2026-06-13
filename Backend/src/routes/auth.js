const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../database/connection');
const { generateMockFinancialData, generateMockTransactions } = require('../services/mockDataGenerator');

const router = express.Router();

router.post('/signup', (req, res) => {
  const { name, email, password, role } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password required' });
  }

  const db = getDatabase();
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  if (existing) {
    return res.status(409).json({ error: 'Email already registered' });
  }

  const userId = uuidv4();
  const hashedPassword = bcrypt.hashSync(password, 10);
  const userRole = ['founder', 'advisor', 'admin'].includes(role) ? role : 'founder';

  db.prepare('INSERT INTO users (id, name, email, password, role) VALUES (?, ?, ?, ?, ?)').run(userId, name, email, hashedPassword, userRole);

  const token = jwt.sign({ userId, role: userRole }, process.env.JWT_SECRET || 'scalable-cfo-demo-secret-key-2026', { expiresIn: '7d' });

  res.status(201).json({
    token,
    user: { id: userId, name, email, role: userRole },
  });
});

router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  const db = getDatabase();
  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }

  const userRole = user.role || 'founder';
  const token = jwt.sign({ userId: user.id, role: userRole }, process.env.JWT_SECRET || 'scalable-cfo-demo-secret-key-2026', { expiresIn: '7d' });

  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(user.id);

  res.json({
    token,
    user: { id: user.id, name: user.name, email: user.email, role: userRole, hasCompany: !!company },
  });
});

router.post('/forgot-password', (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Email required' });
  }

  const db = getDatabase();
  const user = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  if (!user) {
    return res.status(404).json({ error: 'No account with that email' });
  }

  res.json({ message: 'Password reset link sent to your email (demo)' });
});

router.post('/onboarding', (req, res) => {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET || 'scalable-cfo-demo-secret-key-2026');
    const { companyName, industry, monthlyRevenue, monthlyExpenses, employees } = req.body;
    if (!companyName || !industry) {
      return res.status(400).json({ error: 'Company name and industry required' });
    }

    const db = getDatabase();
    const companyId = uuidv4();

    db.prepare('INSERT INTO companies (id, user_id, name, industry, monthly_revenue, monthly_expenses, employees) VALUES (?, ?, ?, ?, ?, ?, ?)').run(companyId, decoded.userId, companyName, industry, monthlyRevenue || 0, monthlyExpenses || 0, employees || 0);

    const financialData = generateMockFinancialData(companyId);
    const insertFinancial = db.prepare('INSERT INTO financial_data (id, company_id, date, revenue, expenses, cash_balance) VALUES (?, ?, ?, ?, ?, ?)');
    for (const d of financialData) {
      insertFinancial.run(d.id, d.company_id, d.date, d.revenue, d.expenses, d.cash_balance);
    }

    const transactions = generateMockTransactions(companyId);
    const insertTxn = db.prepare('INSERT INTO transactions (id, company_id, date, description, amount, type, category) VALUES (?, ?, ?, ?, ?, ?, ?)');
    for (const t of transactions) {
      insertTxn.run(t.id, t.company_id, t.date, t.description, t.amount, t.type, t.category);
    }

    const notificationId = uuidv4();
    db.prepare('INSERT INTO notifications (id, user_id, title, message, type) VALUES (?, ?, ?, ?, ?)').run(notificationId, decoded.userId, 'Welcome to The Scalable CFO', 'Your financial dashboard is ready. Explore insights and track your growth.', 'success');

    res.status(201).json({
      companyId,
      message: 'Company onboarded successfully',
      financialDataGenerated: financialData.length,
    });
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;
