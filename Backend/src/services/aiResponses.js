function getMockResponse(message, context) {
  const lowercase = message.toLowerCase();

  if (lowercase.includes('runway') || lowercase.includes('how long') || lowercase.includes('burn rate')) {
    return {
      text: `Based on your current financial data, let me analyze your runway position.\n\n**Current Runway Analysis:**\n• Cash Balance: $${context.cashBalance?.toLocaleString() || 'N/A'}\n• Monthly Burn Rate: $${context.burnRate?.toLocaleString() || 'N/A'}\n• Estimated Runway: **${context.runway || 'N/A'} months**\n\n**Recommendation:** ${context.runway < 6 ? 'Your runway is below 6 months. I recommend:\n1. Reducing discretionary spending by 15-20%\n2. Accelerating accounts receivable collection\n3. Exploring a bridge round or revenue-based financing\n\nWould you like me to create a detailed runway extension plan?' : context.runway < 12 ? 'Your runway is adequate but should be monitored. Consider:\n1. Maintaining 12+ months runway for investor confidence\n2. Building a financial forecast for the next 2 quarters\n3. Identifying potential cost optimization areas' : 'Your runway position is healthy. This is a good time to focus on growth initiatives. Consider:\n1. Investing in sales and marketing\n2. Evaluating expansion opportunities\n3. Building your financial infrastructure for scale'}`,
      metrics: { cashBalance: context.cashBalance, burnRate: context.burnRate, runway: context.runway },
    };
  }

  if (lowercase.includes('expense') || lowercase.includes('spending') || lowercase.includes('cost')) {
    return {
      text: `Let me analyze your expense trends.\n\n**Current Expense Overview:**\n• Monthly Expenses: $${context.monthlyExpenses?.toLocaleString() || 'N/A'}\n• Largest Categories: ${context.topExpenseCategories || 'Payroll, Infrastructure, Marketing'}\n• Expense-to-Revenue Ratio: ${context.expenseRatio || '72'}%\n\n**Key Insights:**\n1. Your expense ratio of ${context.expenseRatio || '72'}% is ${context.expenseRatio > 80 ? 'above the SaaS benchmark of 65-75%. I recommend reviewing your cost structure.' : 'within the healthy SaaS benchmark range of 65-75%.'}\n2. ${context.employeeCount > 20 ? `With ${context.employeeCount} employees, payroll is likely your biggest expense. Consider evaluating role utilization.` : 'Your team size suggests lean operations, which is positive for efficiency.'}\n3. I recommend a monthly expense review to identify optimization opportunities.\n\nWould you like a detailed expense breakdown by category?`,
      metrics: { totalExpenses: context.monthlyExpenses, expenseRatio: context.expenseRatio },
    };
  }

  if (lowercase.includes('hire') || lowercase.includes('employee') || lowercase.includes('staff') || lowercase.includes('headcount')) {
    const affordable = context.runway > 12 && context.monthlyRevenue > context.monthlyExpenses * 1.2;
    return {
      text: `**Hiring Analysis:**\n\nBased on your financials:\n• Current Headcount: ${context.employeeCount || 'N/A'} employees\n• Monthly Revenue: $${context.monthlyRevenue?.toLocaleString() || 'N/A'}\n• Available Cash: $${context.cashBalance?.toLocaleString() || 'N/A'}\n• Runway: ${context.runway || 'N/A'} months\n\n**Verdict:** ${affordable ? '✅ **Yes, you can afford to hire.** Your revenue covers expenses with a healthy margin, and your runway provides sufficient buffer. Recommended hire cost: $5,000-8,000/month per role.\n\nConsider:\n• Hire for revenue-generating roles first (sales, growth)\n• Use a 3-month probation period\n• Set clear KPIs for the new role' : '⚠️ **Proceed with caution.** Consider:\n1. Your current burn rate and runway position\n2. Hiring on a contract basis first\n3. Ensuring the new role contributes directly to revenue growth\n4. Exploring part-time or fractional talent as an alternative'}\n\nWould you like me to model the financial impact of a specific hire?`,
      metrics: { canHire: affordable, monthlyHireCost: '5,000 - 8,000' },
    };
  }

  if (lowercase.includes('cash flow') || lowercase.includes('trend') || lowercase.includes('revenue trend') || lowercase.includes('financial health')) {
    return {
      text: `**Cash Flow & Revenue Analysis:**\n\n• Current Cash Balance: $${context.cashBalance?.toLocaleString() || 'N/A'}\n• Monthly Revenue: $${context.monthlyRevenue?.toLocaleString() || 'N/A'} (${context.revenueGrowth > 0 ? '+' : ''}${context.revenueGrowth || 0}% growth)\n• Monthly Expenses: $${context.monthlyExpenses?.toLocaleString() || 'N/A'}\n• Net Cash Flow: $${(context.monthlyRevenue - context.monthlyExpenses)?.toLocaleString() || 'N/A'}/month\n\n**Trend Analysis:**\n📈 Revenue is ${context.revenueGrowth > 0 ? `growing at ${context.revenueGrowth}% month-over-month` : 'showing some volatility, which is common for early-stage companies'}.\n📊 Your expense growth of ${context.expenseGrowth || 3}% ${context.expenseGrowth > context.revenueGrowth ? 'is outpacing revenue growth — this needs attention' : 'is well-controlled relative to revenue growth'}.\n💰 Your cash position gives you ${context.runway || 'N/A'} months of runway.\n\n**Recommendations:**\n1. Focus on increasing revenue growth rate to 10%+ MoM\n2. Maintain expense discipline\n3. Build a 12-month financial forecast\n4. Consider opening a high-yield business savings account`,
      metrics: { cashBalance: context.cashBalance, revenueGrowth: context.revenueGrowth, netCashFlow: (context.monthlyRevenue - context.monthlyExpenses) },
    };
  }

  if (lowercase.includes('profit') || lowercase.includes('margin') || lowercase.includes('profitable')) {
    const profit = context.monthlyRevenue - context.monthlyExpenses;
    const margin = context.monthlyRevenue > 0 ? (profit / context.monthlyRevenue * 100) : 0;
    return {
      text: `**Profitability Analysis:**\n\n• Revenue: $${context.monthlyRevenue?.toLocaleString() || 'N/A'}\n• Expenses: $${context.monthlyExpenses?.toLocaleString() || 'N/A'}\n• Net Profit: $${profit?.toLocaleString() || 'N/A'}/month\n• Profit Margin: ${margin.toFixed(1)}%\n\n**Assessment:** ${margin > 20 ? '✅ Strong profitability. Your margin of ' + margin.toFixed(1) + '% exceeds the healthy benchmark. Focus on scaling what works.' : margin > 0 ? '📊 You are profitable with a ' + margin.toFixed(1) + '% margin. There\'s room for improvement through optimization.' : '⚠️ You are currently operating at a loss. This is common for growth-stage companies. Your focus should be on reaching unit profitability.'}\n\n**To improve margins, consider:**\n1. Increasing pricing by 10-15%\n2. Reducing customer acquisition costs\n3. Automating manual processes\n4. Negotiating vendor contracts`,
      metrics: { netProfit: profit, profitMargin: margin.toFixed(1) },
    };
  }

  return {
    text: `Great question! As your CFO, let me provide some perspective.\n\n**Context from your financials:**\n• Company: ${context.companyName || 'Your Company'}\n• Industry: ${context.industry || 'N/A'}\n• Monthly Revenue: $${context.monthlyRevenue?.toLocaleString() || 'N/A'}\n• Cash Balance: $${context.cashBalance?.toLocaleString() || 'N/A'}\n• Runway: ${context.runway || 'N/A'} months\n\n**To give you the most accurate analysis, I recommend asking me about:**\n• Your current runway and burn rate\n• Whether you can afford to hire\n• Expense optimization opportunities\n• Cash flow trends and projections\n• Profitability analysis\n\nWould you like me to dive deeper into any of these areas?`,
    metrics: null,
  };
}

const suggestedQuestions = [
  'What is my current runway?',
  'Why are expenses increasing?',
  'Can I hire another employee?',
  'How is cash flow trending?',
  'Am I profitable?',
  'What should I focus on this quarter?',
];

module.exports = { getMockResponse, suggestedQuestions };
