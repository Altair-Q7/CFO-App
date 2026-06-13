function generateFinancialReport(companyId, financialData) {
  if (!financialData || financialData.length === 0) return null;

  const latest = financialData[financialData.length - 1];
  const previous = financialData.length > 1 ? financialData[financialData.length - 2] : null;
  const totalRevenue = financialData.reduce((sum, d) => sum + d.revenue, 0);
  const totalExpenses = financialData.reduce((sum, d) => sum + d.expenses, 0);
  const avgRevenue = totalRevenue / financialData.length;
  const avgExpenses = totalExpenses / financialData.length;
  const netProfit = latest.revenue - latest.expenses;
  const grossProfit = latest.revenue * 0.7;
  const profitMargin = latest.revenue > 0 ? ((latest.revenue - latest.expenses) / latest.revenue) * 100 : 0;
  const revenueGrowth = previous ? ((latest.revenue - previous.revenue) / previous.revenue) * 100 : 0;

  return {
    totalRevenue,
    totalExpenses,
    avgMonthlyRevenue: Math.round(avgRevenue),
    avgMonthlyExpenses: Math.round(avgExpenses),
    netProfit,
    grossProfit,
    profitMargin: Math.round(profitMargin * 10) / 10,
    revenueGrowth: Math.round(revenueGrowth * 10) / 10,
    operatingRatio: Math.round((avgExpenses / avgRevenue) * 100 * 10) / 10,
    cogs: Math.round(latest.revenue * 0.3),
  };
}

function generateBalanceSheet(financialData) {
  const latest = financialData[financialData.length - 1];
  const cashBalance = latest.cash_balance;
  const accountsReceivable = Math.round(latest.revenue * 0.15);
  const equipment = 150000;
  const totalAssets = cashBalance + accountsReceivable + equipment;

  const accountsPayable = Math.round(latest.expenses * 0.1);
  const deferredRevenue = Math.round(latest.revenue * 0.2);
  const totalLiabilities = accountsPayable + deferredRevenue;

  const retainedEarnings = Math.round(totalAssets * 0.6);
  const totalEquity = retainedEarnings;

  return {
    assets: [
      { name: 'Cash & Cash Equivalents', value: cashBalance },
      { name: 'Accounts Receivable', value: accountsReceivable },
      { name: 'Equipment & Fixed Assets', value: equipment },
    ],
    totalAssets,
    liabilities: [
      { name: 'Accounts Payable', value: accountsPayable },
      { name: 'Deferred Revenue', value: deferredRevenue },
    ],
    totalLiabilities,
    equity: [
      { name: 'Retained Earnings', value: retainedEarnings },
    ],
    totalEquity,
  };
}

function generateCashFlowStatement(financialData) {
  const latest = financialData[financialData.length - 1];
  const previous = financialData.length > 1 ? financialData[financialData.length - 2] : null;

  const netIncome = latest.revenue - latest.expenses;
  const depreciation = 5000;
  const receivablesChange = -Math.round(latest.revenue * 0.05);
  const payablesChange = Math.round(latest.expenses * 0.03);
  const netOperating = netIncome + depreciation + receivablesChange + payablesChange;

  const equipmentPurchase = -25000;
  const netInvesting = equipmentPurchase;

  const loanProceeds = 50000;
  const dividends = -10000;
  const netFinancing = loanProceeds + dividends;

  const netCashChange = netOperating + netInvesting + netFinancing;
  const beginningCash = previous ? previous.cash_balance : latest.cash_balance - netCashChange;
  const endingCash = beginningCash + netCashChange;

  return {
    operating: [
      { description: 'Net Income', value: netIncome },
      { description: 'Depreciation & Amortization', value: depreciation },
      { description: 'Change in Accounts Receivable', value: receivablesChange },
      { description: 'Change in Accounts Payable', value: payablesChange },
    ],
    netOperating,
    investing: [
      { description: 'Equipment Purchase', value: equipmentPurchase },
    ],
    netInvesting,
    financing: [
      { description: 'Loan Proceeds', value: loanProceeds },
      { description: 'Dividends Paid', value: dividends },
    ],
    netFinancing,
    netCashChange,
    beginningCash: Math.round(beginningCash),
    endingCash: Math.round(endingCash),
  };
}

module.exports = { generateFinancialReport, generateBalanceSheet, generateCashFlowStatement };
