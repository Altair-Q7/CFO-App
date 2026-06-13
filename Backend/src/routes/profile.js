const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, (req, res) => {
  const db = getDatabase();
  const user = db.prepare('SELECT id, name, email, created_at FROM users WHERE id = ?').get(req.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);

  res.json({
    user,
    company: company || null,
  });
});

router.put('/', authenticate, (req, res) => {
  const { name, companyName, industry, monthlyRevenue, monthlyExpenses, employees } = req.body;
  const db = getDatabase();

  if (name) {
    db.prepare('UPDATE users SET name = ? WHERE id = ?').run(name, req.userId);
  }

  const company = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);
  if (company) {
    const updates = [];
    const params = [];
    if (companyName) { updates.push('name = ?'); params.push(companyName); }
    if (industry) { updates.push('industry = ?'); params.push(industry); }
    if (monthlyRevenue) { updates.push('monthly_revenue = ?'); params.push(monthlyRevenue); }
    if (monthlyExpenses) { updates.push('monthly_expenses = ?'); params.push(monthlyExpenses); }
    if (employees) { updates.push('employees = ?'); params.push(employees); }

    if (updates.length > 0) {
      params.push(company.id);
      db.prepare(`UPDATE companies SET ${updates.join(', ')} WHERE id = ?`).run(...params);
    }
  }

  const updatedUser = db.prepare('SELECT id, name, email, created_at FROM users WHERE id = ?').get(req.userId);
  const updatedCompany = db.prepare('SELECT * FROM companies WHERE user_id = ?').get(req.userId);

  res.json({
    user: updatedUser,
    company: updatedCompany || null,
  });
});

module.exports = router;
