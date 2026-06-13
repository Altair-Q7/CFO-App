const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');
const { calculateRunway } = require('../services/forecastingEngine');

const router = express.Router();

router.get('/metrics', authenticate, (req, res) => {
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const data = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);
  if (data.length === 0) return res.json({ metrics: null });

  const latest = data[data.length - 1];
  const prevMonth = data.length > 1 ? data[data.length - 2] : latest;
  const avgExpenses = data.reduce((s, d) => s + d.expenses, 0) / data.length;
  const burnRate = avgExpenses - (avgExpenses * 0.2);
  const runway = calculateRunway(latest.cash_balance, burnRate);

  const revenueChange = prevMonth ? ((latest.revenue - prevMonth.revenue) / prevMonth.revenue) * 100 : 0;
  const expenseChange = prevMonth ? ((latest.expenses - prevMonth.expenses) / prevMonth.expenses) * 100 : 0;

  res.json({
    cashBalance: latest.cash_balance,
    monthlyRevenue: latest.revenue,
    monthlyExpenses: latest.expenses,
    netProfit: latest.revenue - latest.expenses,
    burnRate: Math.round(burnRate),
    runway,
    revenueChange: Math.round(revenueChange * 10) / 10,
    expenseChange: Math.round(expenseChange * 10) / 10,
    profitMargin: Math.round(((latest.revenue - latest.expenses) / latest.revenue) * 1000) / 10,
    companyName: company.name,
    industry: company.industry,
    employees: company.employees,
  });
});

router.get('/trends', authenticate, (req, res) => {
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const data = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);

  const trends = data.map(d => ({
    date: d.date,
    revenue: d.revenue,
    expenses: d.expenses,
    cashBalance: d.cash_balance,
  }));

  res.json({ trends });
});

router.get('/activity', authenticate, (req, res) => {
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const transactions = db.prepare('SELECT * FROM transactions WHERE company_id = ? ORDER BY date DESC LIMIT 15').all(company.id);
  const notifications = db.prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 5').all(req.userId);

  res.json({ transactions, notifications });
});

module.exports = router;
