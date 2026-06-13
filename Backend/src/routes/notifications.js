const express = require('express');
const { getDatabase } = require('../database/connection');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, (req, res) => {
  const db = getDatabase();
  const notifications = db.prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50').all(req.userId);

  const unreadCount = notifications.filter(n => !n.read).length;

  res.json({ notifications, unreadCount });
});

router.patch('/:id/read', authenticate, (req, res) => {
  const db = getDatabase();
  const result = db.prepare('UPDATE notifications SET read = 1 WHERE id = ? AND user_id = ?').run(req.params.id, req.userId);

  if (result.changes === 0) return res.status(404).json({ error: 'Notification not found' });

  res.json({ message: 'Marked as read' });
});

router.post('/mark-all-read', authenticate, (req, res) => {
  const db = getDatabase();
  db.prepare('UPDATE notifications SET read = 1 WHERE user_id = ?').run(req.userId);
  res.json({ message: 'All notifications marked as read' });
});

module.exports = router;
