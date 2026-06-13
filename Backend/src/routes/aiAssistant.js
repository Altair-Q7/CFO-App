const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');
const { getMockResponse, suggestedQuestions } = require('../services/aiResponses');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

router.post('/chat', authenticate, (req, res) => {
  const { message, history = [] } = req.body;
  if (!message) return res.status(400).json({ error: 'Message required' });

  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  const data = company ? db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id) : [];

  const latest = data.length > 0 ? data[data.length - 1] : null;
  const prevMonth = data.length > 1 ? data[data.length - 2] : null;
  const avgExpenses = data.length > 0 ? data.reduce((s, d) => s + d.expenses, 0) / data.length : 0;
  const burnRate = avgExpenses * 0.8;
  const runway = latest && burnRate > 0 ? Math.round(latest.cash_balance / burnRate) : 0;

  const context = {
    companyName: company?.name || 'Your Company',
    industry: company?.industry || 'N/A',
    cashBalance: latest?.cash_balance || 0,
    monthlyRevenue: latest?.revenue || 0,
    monthlyExpenses: latest?.expenses || 0,
    burnRate: Math.round(burnRate),
    runway,
    revenueGrowth: prevMonth ? Math.round(((latest.revenue - prevMonth.revenue) / prevMonth.revenue) * 100) : 0,
    expenseGrowth: prevMonth ? Math.round(((latest.expenses - prevMonth.expenses) / prevMonth.expenses) * 100) : 0,
    expenseRatio: latest ? Math.round((latest.expenses / latest.revenue) * 100) : 0,
    employeeCount: company?.employees || 0,
    topExpenseCategories: 'Payroll (45%), Infrastructure (20%), Marketing (15%), Software (12%), Other (8%)',
  };

  const response = getMockResponse(message, context);

  db.prepare('INSERT INTO chat_history (id, user_id, role, content) VALUES (?, ?, ?, ?)').run(uuidv4(), req.userId, 'user', message);
  db.prepare('INSERT INTO chat_history (id, user_id, role, content) VALUES (?, ?, ?, ?)').run(uuidv4(), req.userId, 'assistant', response.text);

  res.json({
    response: response.text,
    metrics: response.metrics,
    suggestedQuestions,
  });
});

router.get('/history', authenticate, (req, res) => {
  const db = getDatabase();
  const history = db.prepare('SELECT * FROM chat_history WHERE user_id = ? ORDER BY created_at ASC LIMIT 50').all(req.userId);
  res.json({ history });
});

router.get('/suggestions', (req, res) => {
  res.json({ suggestions: suggestedQuestions });
});

module.exports = router;
