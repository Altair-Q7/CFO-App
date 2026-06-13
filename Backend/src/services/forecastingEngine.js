function projectForecast(historicalData, options = {}) {
  const { months = 12, revenueGrowth = 5, expenseGrowth = 3, hiringCost = 0 } = options;

  const lastEntry = historicalData[historicalData.length - 1];
  let cash = lastEntry.cash_balance;
  let revenue = lastEntry.revenue;
  let expenses = lastEntry.expenses;

  const projections = [];
  const now = new Date();

  for (let i = 1; i <= months; i++) {
    const date = new Date(now);
    date.setMonth(date.getMonth() + i);

    const revGrowth = revenueGrowth / 100;
    const expGrowth = expenseGrowth / 100;
    const hireCostMonthly = hiringCost > 0 ? hiringCost / 12 : 0;

    revenue = Math.round(revenue * (1 + revGrowth / 12));
    expenses = Math.round(expenses * (1 + expGrowth / 12) + hireCostMonthly);
    cash = cash + revenue - expenses;

    projections.push({
      date: date.toISOString().split('T')[0],
      revenue,
      expenses,
      cash_balance: Math.round(cash),
      month: i,
    });
  }

  return projections;
}

function calculateRunway(cashBalance, monthlyBurn) {
  if (monthlyBurn <= 0) return 999;
  return Math.round(cashBalance / monthlyBurn);
}

module.exports = { projectForecast, calculateRunway };
