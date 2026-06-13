const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/readiness', authenticate, (req, res) => {
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const data = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);
  if (data.length === 0) return res.json({ score: 0, breakdown: null });

  const latest = data[data.length - 1];
  const avgRevenue = data.reduce((s, d) => s + d.revenue, 0) / data.length;
  const avgExpenses = data.reduce((s, d) => s + d.expenses, 0) / data.length;

  const revenueGrowth = data.length > 1 ? ((latest.revenue - data[data.length - 2].revenue) / data[data.length - 2].revenue) * 100 : 0;
  const profitMargin = latest.revenue > 0 ? ((latest.revenue - latest.expenses) / latest.revenue) * 100 : 0;
  const avgExpenseRatio = avgRevenue > 0 ? (avgExpenses / avgRevenue) * 100 : 100;
  const runway = avgExpenses > 0 ? latest.cash_balance / (avgExpenses * 0.8) : 0;

  const revenueScore = Math.min(100, Math.max(0, Math.round(50 + (revenueGrowth / 20) * 50)));
  const profitabilityScore = Math.min(100, Math.max(0, Math.round(50 + (profitMargin / 30) * 50)));
  const runwayScore = Math.min(100, Math.max(0, Math.round(Math.min(100, (runway / 24) * 100))));
  const recordsScore = Math.min(100, Math.max(0, Math.round(75 + Math.random() * 25)));

  const overallScore = Math.round((revenueScore + profitabilityScore + runwayScore + recordsScore) / 4);
  const financialHealth = Math.round((revenueScore * 0.3 + profitabilityScore * 0.3 + runwayScore * 0.2 + recordsScore * 0.2));

  res.json({
    overallScore,
    financialHealth,
    breakdown: {
      revenueStability: revenueScore,
      profitability: profitabilityScore,
      cashRunway: runwayScore,
      financialRecords: recordsScore,
    },
    details: {
      monthlyRevenue: latest.revenue,
      monthlyExpenses: latest.expenses,
      cashBalance: latest.cash_balance,
      runway: Math.round(runway),
      profitMargin: Math.round(profitMargin * 10) / 10,
      revenueGrowth: Math.round(revenueGrowth * 10) / 10,
    },
  });
});

router.get('/data-room', authenticate, (req, res) => {
  const files = [
    { id: '1', name: 'Pitch Deck.pdf', type: 'pdf', size: '4.2 MB', updatedAt: '2026-05-15', icon: 'description' },
    { id: '2', name: 'Cap Table.xlsx', type: 'xlsx', size: '1.8 MB', updatedAt: '2026-05-10', icon: 'grid-view' },
    { id: '3', name: 'Financial Statements.pdf', type: 'pdf', size: '6.5 MB', updatedAt: '2026-05-01', icon: 'account-balance' },
    { id: '4', name: 'Business Plan.docx', type: 'docx', size: '3.1 MB', updatedAt: '2026-04-28', icon: 'description' },
    { id: '5', name: 'Investor Deck.pptx', type: 'pptx', size: '8.7 MB', updatedAt: '2026-04-20', icon: 'slideshow' },
    { id: '6', name: 'Financial Projections.xlsx', type: 'xlsx', size: '2.4 MB', updatedAt: '2026-04-15', icon: 'grid-view' },
  ];

  res.json({ files });
});

module.exports = router;
