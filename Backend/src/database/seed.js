const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
const { getDatabase } = require('./connection');

function seedDatabase(db) {
  const count = db.prepare('SELECT COUNT(*) as count FROM advisors').get();
  if (count.count > 0) return;

  const advisors = [
    { id: uuidv4(), name: 'Sarah Chen', photo: 'https://i.pravatar.cc/150?u=sarah', experience: 15, rating: 4.9, specialization: 'SaaS & Enterprise', region: 'North America', bio: 'Former CFO of three unicorn startups. Specializing in SaaS metrics, fundraising strategy, and financial operations at scale.', price_per_hour: 250 },
    { id: uuidv4(), name: 'Marcus Johnson', photo: 'https://i.pravatar.cc/150?u=marcus', experience: 12, rating: 4.8, specialization: 'Early Stage Growth', region: 'Europe', bio: 'Helped 50+ startups from pre-seed to Series B. Expert in unit economics, runway optimization, and investor relations.', price_per_hour: 200 },
    { id: uuidv4(), name: 'Priya Patel', photo: 'https://i.pravatar.cc/150?u=priya', experience: 18, rating: 4.9, specialization: 'Fintech & Compliance', region: 'Asia Pacific', bio: 'Big 4 trained CFO with deep fintech expertise. Regulatory compliance, risk management, and international expansion.', price_per_hour: 300 },
    { id: uuidv4(), name: 'James Wilson', photo: 'https://i.pravatar.cc/150?u=james', experience: 10, rating: 4.7, specialization: 'E-commerce & D2C', region: 'North America', bio: 'Growth-stage CFO who scaled 3 D2C brands to $100M+ revenue. Inventory management, cash flow optimization, and FP&A.', price_per_hour: 180 },
    { id: uuidv4(), name: 'Elena Rodriguez', photo: 'https://i.pravatar.cc/150?u=elena', experience: 14, rating: 4.8, specialization: 'Healthcare & Biotech', region: 'Europe', bio: 'CFO with PhD in Health Economics. Specialized in medtech, biotech fundraising, and healthcare financial modeling.', price_per_hour: 275 },
    { id: uuidv4(), name: 'David Kim', photo: 'https://i.pravatar.cc/150?u=david', experience: 20, rating: 4.9, specialization: 'M&A & Corporate Strategy', region: 'Asia Pacific', bio: 'Former investment banker turned CFO. M&A strategy, corporate restructuring, and capital markets expertise.', price_per_hour: 350 },
  ];

  const insertAdvisor = db.prepare(`INSERT INTO advisors (id, name, photo, experience, rating, specialization, region, bio, availability, price_per_hour) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Available', ?)`);

  const insertReview = db.prepare(`INSERT INTO reviews (id, advisor_id, user_id, rating, comment, created_at) VALUES (?, ?, ?, ?, ?, ?)`);

  const transaction = db.transaction(() => {
    for (const a of advisors) {
      insertAdvisor.run(a.id, a.name, a.photo, a.experience, a.rating, a.specialization, a.region, a.bio, a.price_per_hour);

      const reviewTexts = [
        'Exceptional financial insight. Transformed our fundraising strategy.',
        'Incredible depth of knowledge. Highly recommend for any startup.',
        'Practical advice that saved us months of runway.',
        'Best financial advisor we have worked with.',
        'Helped us prepare for Series A in record time.',
      ];
      for (let i = 0; i < 3; i++) {
        const rating = Math.floor(Math.random() * 2) + 4;
        insertReview.run(uuidv4(), a.id, null, rating, reviewTexts[i % reviewTexts.length], new Date(Date.now() - i * 86400000).toISOString());
      }
    }
  });

  transaction();
  console.log('Database seeded with advisors');
}

module.exports = { seedDatabase };
