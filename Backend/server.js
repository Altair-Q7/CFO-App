require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { initializeDatabase } = require('./src/database/connection');
const { seedDatabase } = require('./src/database/seed');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/dashboard', require('./src/routes/dashboard'));
app.use('/api/forecasting', require('./src/routes/forecasting'));
app.use('/api/ai', require('./src/routes/aiAssistant'));
app.use('/api/reports', require('./src/routes/reports'));
app.use('/api/marketplace', require('./src/routes/marketplace'));
app.use('/api/fundraising', require('./src/routes/fundraising'));
app.use('/api/notifications', require('./src/routes/notifications'));
app.use('/api/profile', require('./src/routes/profile'));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', app: 'The Scalable CFO API' });
});

const db = initializeDatabase();
seedDatabase(db);

app.listen(PORT, () => {
  console.log(`Scalable CFO API running on port ${PORT}`);
});

module.exports = app;
