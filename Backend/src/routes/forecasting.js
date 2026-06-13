const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');
const { projectForecast } = require('../services/forecastingEngine');

const router = express.Router();

router.post('/project', authenticate, (req, res) => {
  const { months = 12, revenueGrowth = 5, expenseGrowth = 3, hiringCost = 0 } = req.body;
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const historical = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);
  if (historical.length === 0) return res.status(400).json({ error: 'No financial data' });

  const projections = projectForecast(historical, {
    months: Math.min(months, 365),
    revenueGrowth: parseFloat(revenueGrowth) || 0,
    expenseGrowth: parseFloat(expenseGrowth) || 0,
    hiringCost: parseFloat(hiringCost) || 0,
  });

  const latest = historical[historical.length - 1];
  const avgExpenses = historical.reduce((s, d) => s + d.expenses, 0) / historical.length;
  const burnRate = avgExpenses * 0.8;
  const runway = burnRate > 0 ? Math.round(latest.cash_balance / burnRate) : 999;

  res.json({
    historical: historical.map(d => ({
      date: d.date,
      revenue: d.revenue,
      expenses: d.expenses,
      cashBalance: d.cash_balance,
      actual: true,
    })),
    projections,
    currentCash: latest.cash_balance,
    currentBurnRate: Math.round(burnRate),
    currentRunway: runway,
  });
});

module.exports = router;
