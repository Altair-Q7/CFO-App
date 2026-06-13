const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

router.get('/advisors', (req, res) => {
  const { industry, rating, region, search } = req.query;
  const db = getDatabase();

  let query = 'SELECT * FROM advisors WHERE 1=1';
  const params = [];

  if (industry) {
    query += ' AND specialization LIKE ?';
    params.push(`%${industry}%`);
  }
  if (rating) {
    query += ' AND rating >= ?';
    params.push(parseFloat(rating));
  }
  if (region) {
    query += ' AND region LIKE ?';
    params.push(`%${region}%`);
  }
  if (search) {
    query += ' AND (name LIKE ? OR specialization LIKE ? OR bio LIKE ?)';
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }

  query += ' ORDER BY rating DESC';

  const advisors = db.prepare(query).all(...params);
  res.json({ advisors });
});

router.get('/advisors/:id', (req, res) => {
  const db = getDatabase();
  const advisor = db.prepare('SELECT * FROM advisors WHERE id = ?').get(req.params.id);
  if (!advisor) return res.status(404).json({ error: 'Advisor not found' });

  const reviews = db.prepare('SELECT * FROM reviews WHERE advisor_id = ? ORDER BY created_at DESC').all(req.params.id);

  res.json({ advisor, reviews });
});

router.post('/book', authenticate, (req, res) => {
  const { advisorId, date } = req.body;
  if (!advisorId || !date) return res.status(400).json({ error: 'Advisor ID and date required' });

  const db = getDatabase();
  const advisor = db.prepare('SELECT * FROM advisors WHERE id = ?').get(advisorId);
  if (!advisor) return res.status(404).json({ error: 'Advisor not found' });

  const bookingId = uuidv4();
  db.prepare('INSERT INTO bookings (id, user_id, advisor_id, date, status) VALUES (?, ?, ?, ?, ?)').run(bookingId, req.userId, advisorId, date, 'confirmed');

  const notificationId = uuidv4();
  db.prepare('INSERT INTO notifications (id, user_id, title, message, type) VALUES (?, ?, ?, ?, ?)').run(notificationId, req.userId, 'Consultation Booked', `Your consultation with ${advisor.name} on ${new Date(date).toLocaleDateString()} has been confirmed.`, 'success');

  res.status(201).json({
    bookingId,
    message: `Consultation booked with ${advisor.name} on ${new Date(date).toLocaleDateString()}`,
  });
});

module.exports = router;
