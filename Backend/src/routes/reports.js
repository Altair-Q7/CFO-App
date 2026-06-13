const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');
const { generateFinancialReport, generateBalanceSheet, generateCashFlowStatement } = require('../utils/helpers');
const { generateReportPDF } = require('../services/pdfGenerator');

const router = express.Router();

router.get('/:type', authenticate, (req, res) => {
  const { type } = req.params;
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const data = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);
  if (data.length === 0) return res.status(404).json({ error: 'No financial data' });

  const reportMap = {
    'pnl': { name: 'Profit & Loss Statement', fn: () => generateFinancialReport(company.id, data) },
    'balance-sheet': { name: 'Balance Sheet', fn: () => generateBalanceSheet(data) },
    'cash-flow': { name: 'Cash Flow Statement', fn: () => generateCashFlowStatement(data) },
  };

  const report = reportMap[type];
  if (!report) return res.status(400).json({ error: 'Invalid report type. Use: pnl, balance-sheet, cash-flow' });

  res.json({
    type: report.name,
    data: report.fn(),
    company,
  });
});

router.get('/:type/pdf', authenticate, async (req, res) => {
  const { type } = req.params;
  const db = getDatabase();
  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (!company) return res.status(404).json({ error: 'No company found' });

  const data = db.prepare('SELECT * FROM financial_data WHERE company_id = ? ORDER BY date ASC').all(company.id);
  if (data.length === 0) return res.status(404).json({ error: 'No financial data' });

  const reportMap = {
    'pnl': { name: 'Profit & Loss Statement', fn: () => generateFinancialReport(company.id, data) },
    'balance-sheet': { name: 'Balance Sheet', fn: () => generateBalanceSheet(data) },
    'cash-flow': { name: 'Cash Flow Statement', fn: () => generateCashFlowStatement(data) },
  };

  const report = reportMap[type];
  if (!report) return res.status(400).json({ error: 'Invalid report type' });

  const reportData = report.fn();
  const pdfBuffer = await generateReportPDF(report.name, reportData, company);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="${type}-report.pdf"`);
  res.send(pdfBuffer);
});

module.exports = router;
