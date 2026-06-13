const { v4: uuidv4 } = require('uuid');

function generateMockFinancialData(companyId) {
  const data = [];
  const startCash = 500000 + Math.random() * 500000;
  let cash = startCash;

  for (let month = 11; month >= 0; month--) {
    const date = new Date();
    date.setMonth(date.getMonth() - month);
    const dateStr = date.toISOString().split('T')[0];

    const baseRevenue = 80000 + Math.random() * 40000;
    const growthFactor = 1 + (11 - month) * 0.05;
    const revenue = Math.round(baseRevenue * growthFactor);
    const expenses = Math.round(revenue * (0.65 + Math.random() * 0.15));
    cash = cash + revenue - expenses;

    data.push({
      id: uuidv4(),
      company_id: companyId,
      date: dateStr,
      revenue,
      expenses,
      cash_balance: Math.round(cash),
    });
  }

  return data;
}

function generateMockTransactions(companyId) {
  const descriptions = [
    { income: ['Client payment - Acme Corp', 'SaaS subscription revenue', 'Consulting fees - TechCo', 'Product sales - Q4', 'Service contract - Innovate Inc', 'License renewal - DataSys', 'Partnership revenue - CloudNet', 'Onboarding fees - New clients'], expense: ['Office rent', 'Cloud infrastructure - AWS', 'Employee salaries', 'Marketing campaign - Google Ads', 'Software licenses - SaaS tools', 'Legal & compliance fees', 'Insurance premium', 'Travel & entertainment', 'Equipment lease', 'Consulting services'] },
  ];

  const transactions = [];
  const incomeDesc = ['Client payment - Acme Corp', 'SaaS subscription revenue', 'Consulting fees - TechCo', 'Product sales - Q4', 'Service contract - Innovate Inc', 'License renewal - DataSys', 'Partnership revenue - CloudNet', 'Onboarding fees - New clients'];
  const expenseDesc = ['Office rent', 'Cloud infrastructure - AWS', 'Employee salaries', 'Marketing campaign - Google Ads', 'Software licenses - SaaS tools', 'Legal & compliance fees', 'Insurance premium', 'Travel & entertainment', 'Equipment lease', 'Consulting services - External'];
  const categories = ['Revenue', 'Subscriptions', 'Services', 'Products', 'Contracts', 'Licenses', 'Partnerships', 'Fees'];

  const expenseCategories = ['Operations', 'Infrastructure', 'Payroll', 'Marketing', 'Software', 'Legal', 'Insurance', 'Travel', 'Equipment', 'Professional'];

  for (let i = 0; i < 20; i++) {
    const date = new Date();
    date.setDate(date.getDate() - Math.floor(Math.random() * 90));
    const isIncome = Math.random() > 0.45;

    transactions.push({
      id: uuidv4(),
      company_id: companyId,
      date: date.toISOString().split('T')[0],
      description: isIncome ? incomeDesc[Math.floor(Math.random() * incomeDesc.length)] : expenseDesc[Math.floor(Math.random() * expenseDesc.length)],
      amount: Math.round((isIncome ? 5000 + Math.random() * 45000 : 2000 + Math.random() * 15000) * 100) / 100,
      type: isIncome ? 'income' : 'expense',
      category: isIncome ? categories[Math.floor(Math.random() * categories.length)] : expenseCategories[Math.floor(Math.random() * expenseCategories.length)],
    });
  }

  return transactions;
}

module.exports = { generateMockFinancialData, generateMockTransactions };
