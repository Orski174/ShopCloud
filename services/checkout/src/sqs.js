const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const clientConfig = { region: process.env.AWS_REGION || 'us-east-1' };

if (process.env.SQS_ENDPOINT) {
  clientConfig.endpoint = process.env.SQS_ENDPOINT;
  clientConfig.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'local',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'local',
  };
}

const sqsClient = new SQSClient(clientConfig);

async function publishInvoiceJob(payload) {
  if (!process.env.SQS_INVOICE_QUEUE_URL) {
    console.warn('SQS_INVOICE_QUEUE_URL not set — skipping invoice queue publish');
    return;
  }
  await sqsClient.send(
    new SendMessageCommand({
      QueueUrl: process.env.SQS_INVOICE_QUEUE_URL,
      MessageBody: JSON.stringify(payload),
    })
  );
}

module.exports = { publishInvoiceJob };
