const { generateInvoicePDF } = require('./pdf');
const { uploadToS3, sendInvoiceEmail } = require('./aws');

/**
 * Processes a single invoice job payload.
 * @param {object} payload  { orderId, userId, email, items, total, shippingAddress }
 */
async function processInvoiceJob(payload) {
  const { orderId, email, items, total, shippingAddress } = payload;

  console.log(`Processing invoice for order ${orderId}`);

  const pdfBuffer = await generateInvoicePDF({ orderId, email, items, total, shippingAddress });

  const s3Key = `invoices/${orderId}.pdf`;
  const s3Uri = await uploadToS3(s3Key, pdfBuffer);
  console.log(`Invoice uploaded to ${s3Uri}`);

  await sendInvoiceEmail(email, orderId, pdfBuffer);
  console.log(`Invoice email sent to ${email}`);

  return { orderId, s3Uri };
}

module.exports = { processInvoiceJob };
