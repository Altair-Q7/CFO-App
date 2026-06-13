const PDFDocument = require('pdfkit');

function generateReportPDF(type, data, company) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    const chunks = [];

    doc.on('data', chunk => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    doc.fontSize(24).font('Helvetica-Bold').text('The Scalable CFO', { align: 'center' });
    doc.fontSize(12).font('Helvetica').text(company.name, { align: 'center' });
    doc.text(`Industry: ${company.industry}`, { align: 'center' });
    doc.moveDown(0.5);
    doc.text(`Report: ${type}`, { align: 'center' });
    doc.text(`Generated: ${new Date().toLocaleDateString()}`, { align: 'center' });
    doc.moveDown(1);

    doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke('#0B1F3A');
    doc.moveDown(1);

    if (type === 'Profit & Loss Statement') {
      doc.fontSize(16).font('Helvetica-Bold').text('Profit & Loss Statement', { align: 'center' });
      doc.moveDown(0.5);

      const headers = ['Category', 'Amount ($)'];
      const rows = [
        ['Revenue', data.totalRevenue?.toLocaleString() || '0'],
        ['Cost of Goods Sold', data.cogs?.toLocaleString() || '0'],
        ['Gross Profit', data.grossProfit?.toLocaleString() || '0'],
        ['Operating Expenses', data.totalExpenses?.toLocaleString() || '0'],
        ['Net Profit', data.netProfit?.toLocaleString() || '0'],
      ];

      doc.fontSize(10);
      rows.forEach((row, i) => {
        const isLast = i === rows.length - 1;
        doc.font(isLast ? 'Helvetica-Bold' : 'Helvetica').text(`${row[0]}:`, { continued: true });
        doc.text(` $${row[1]}`, { align: 'right' });
        if (isLast) doc.moveDown(0.3);
      });

      doc.moveDown(1);
      doc.fontSize(11).font('Helvetica');
      const metrics = [
        `Revenue Growth: ${data.revenueGrowth || 0}%`,
        `Profit Margin: ${data.profitMargin || 0}%`,
        `Operating Ratio: ${data.operatingRatio || 0}%`,
      ];
      metrics.forEach(m => doc.text(`• ${m}`));
    }

    else if (type === 'Balance Sheet') {
      doc.fontSize(16).font('Helvetica-Bold').text('Balance Sheet', { align: 'center' });
      doc.moveDown(0.5);
      doc.fontSize(11).font('Helvetica');

      doc.font('Helvetica-Bold').text('Assets', { underline: true });
      doc.font('Helvetica');
      (data.assets || []).forEach(a => doc.text(`  ${a.name}: $${a.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Total Assets: $${data.totalAssets?.toLocaleString() || 0}`);
      doc.moveDown(0.5);

      doc.font('Helvetica-Bold').text('Liabilities', { underline: true });
      doc.font('Helvetica');
      (data.liabilities || []).forEach(l => doc.text(`  ${l.name}: $${l.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Total Liabilities: $${data.totalLiabilities?.toLocaleString() || 0}`);
      doc.moveDown(0.5);

      doc.font('Helvetica-Bold').text('Equity', { underline: true });
      doc.font('Helvetica');
      (data.equity || []).forEach(e => doc.text(`  ${e.name}: $${e.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Total Equity: $${data.totalEquity?.toLocaleString() || 0}`);
    }

    else if (type === 'Cash Flow Statement') {
      doc.fontSize(16).font('Helvetica-Bold').text('Cash Flow Statement', { align: 'center' });
      doc.moveDown(0.5);
      doc.fontSize(11).font('Helvetica');

      doc.font('Helvetica-Bold').text('Operating Activities', { underline: true });
      doc.font('Helvetica');
      (data.operating || []).forEach(o => doc.text(`  ${o.description}: $${o.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Net Operating: $${data.netOperating?.toLocaleString() || 0}`);
      doc.moveDown(0.3);

      doc.font('Helvetica-Bold').text('Investing Activities', { underline: true });
      doc.font('Helvetica');
      (data.investing || []).forEach(i => doc.text(`  ${i.description}: $${i.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Net Investing: $${data.netInvesting?.toLocaleString() || 0}`);
      doc.moveDown(0.3);

      doc.font('Helvetica-Bold').text('Financing Activities', { underline: true });
      doc.font('Helvetica');
      (data.financing || []).forEach(f => doc.text(`  ${f.description}: $${f.value.toLocaleString()}`));
      doc.font('Helvetica-Bold').text(`Net Financing: $${data.netFinancing?.toLocaleString() || 0}`);
      doc.moveDown(0.5);

      doc.font('Helvetica-Bold').text(`Net Cash Change: $${data.netCashChange?.toLocaleString() || 0}`);
      doc.text(`Beginning Cash: $${data.beginningCash?.toLocaleString() || 0}`);
      doc.font('Helvetica-Bold').text(`Ending Cash: $${data.endingCash?.toLocaleString() || 0}`);
    }

    doc.moveDown(2);
    doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke('#0B1F3A');
    doc.moveDown(0.5);
    doc.fontSize(8).font('Helvetica').text('This report is generated for demo purposes by The Scalable CFO platform.', { align: 'center' });
    doc.text(`© ${new Date().getFullYear()} The Scalable CFO. All rights reserved.`, { align: 'center' });

    doc.end();
  });
}

module.exports = { generateReportPDF };
