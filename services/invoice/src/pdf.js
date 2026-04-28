const PDFDocument = require('pdfkit');

/**
 * Generates a PDF invoice buffer for an order.
 * @param {object} order  { orderId, email, items, total, shippingAddress }
 * @returns {Promise<Buffer>}
 */
function generateInvoicePDF(order) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const chunks = [];

    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const { orderId, email, items, total, shippingAddress } = order;

    // Header
    doc.fontSize(24).font('Helvetica-Bold').text('ShopCloud', 50, 50);
    doc.fontSize(10).font('Helvetica').fillColor('#555').text('E-Commerce Platform', 50, 80);
    doc.moveDown();

    // Invoice title
    doc.fontSize(18).fillColor('#000').font('Helvetica-Bold').text('INVOICE', { align: 'right' });
    doc.fontSize(10).font('Helvetica').text(`Order ID: ${orderId}`, { align: 'right' });
    doc.text(`Date: ${new Date().toLocaleDateString('en-US')}`, { align: 'right' });

    doc.moveDown(2);

    // Customer
    doc.font('Helvetica-Bold').fontSize(12).text('Billed To:');
    doc.font('Helvetica').fontSize(10).text(email);
    if (shippingAddress) {
      doc.text(shippingAddress.line1 || '');
      if (shippingAddress.line2) doc.text(shippingAddress.line2);
      doc.text(`${shippingAddress.city || ''}, ${shippingAddress.country || ''}`);
    }

    doc.moveDown(2);

    // Items table header
    const tableTop = doc.y;
    doc
      .font('Helvetica-Bold')
      .fontSize(10)
      .text('Product', 50, tableTop)
      .text('Qty', 350, tableTop)
      .text('Unit Price', 400, tableTop)
      .text('Subtotal', 480, tableTop);

    doc.moveTo(50, tableTop + 15).lineTo(540, tableTop + 15).stroke();

    let y = tableTop + 25;
    doc.font('Helvetica').fontSize(10);

    for (const item of items) {
      const subtotal = (parseFloat(item.price) * item.quantity).toFixed(2);
      doc.text(item.name, 50, y, { width: 290, ellipsis: true });
      doc.text(String(item.quantity), 350, y);
      doc.text(`$${parseFloat(item.price).toFixed(2)}`, 400, y);
      doc.text(`$${subtotal}`, 480, y);
      y += 20;
    }

    doc.moveTo(50, y).lineTo(540, y).stroke();
    y += 10;

    // Total
    doc.font('Helvetica-Bold').fontSize(12).text(`Total: $${parseFloat(total).toFixed(2)}`, 400, y);

    doc.moveDown(4);
    doc.font('Helvetica').fontSize(9).fillColor('#888').text(
      'Payment is simulated. Thank you for shopping with ShopCloud.',
      50,
      null,
      { align: 'center' }
    );

    doc.end();
  });
}

module.exports = { generateInvoicePDF };
