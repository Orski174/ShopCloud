const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

function buildAwsConfig() {
  const cfg = { region: process.env.AWS_REGION || 'us-east-1' };
  if (process.env.NODE_ENV !== 'production') {
    cfg.credentials = {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'local',
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'local',
    };
  }
  return cfg;
}

const s3Client = new S3Client({
  ...buildAwsConfig(),
  ...(process.env.S3_ENDPOINT ? { endpoint: process.env.S3_ENDPOINT, forcePathStyle: true } : {}),
});

const sesClient = new SESClient(buildAwsConfig());

async function uploadToS3(key, buffer) {
  await s3Client.send(
    new PutObjectCommand({
      Bucket: process.env.S3_BUCKET || 'shopcloud-invoices',
      Key: key,
      Body: buffer,
      ContentType: 'application/pdf',
    })
  );
  return `s3://${process.env.S3_BUCKET || 'shopcloud-invoices'}/${key}`;
}

async function sendInvoiceEmail(toEmail, orderId, pdfBuffer) {
  const fromEmail = process.env.SES_FROM_EMAIL || 'noreply@shopcloud.example.com';
  try {
    await sesClient.send(
      new SendEmailCommand({
        Source: fromEmail,
        Destination: { ToAddresses: [toEmail] },
        Message: {
          Subject: { Data: `ShopCloud - Invoice for Order #${orderId}` },
          Body: {
            Text: {
              Data: `Thank you for your order!\n\nYour invoice for order #${orderId} has been generated and stored successfully.\n\nShopCloud Team`,
            },
          },
        },
      })
    );
  } catch (err) {
    // SES sandbox may reject in dev; log and continue.
    console.warn(`SES send failed for ${toEmail}:`, err.message);
  }
}

module.exports = { uploadToS3, sendInvoiceEmail };
