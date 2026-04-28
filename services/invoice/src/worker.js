/**
 * SQS long-poll worker — polls the invoice queue and processes jobs.
 * Runs as a standalone process alongside (or instead of) the HTTP server.
 */
require('dotenv').config();
const { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs');
const { processInvoiceJob } = require('./invoiceProcessor');

const QUEUE_URL = process.env.SQS_INVOICE_QUEUE_URL;

const sqsConfig = {
  region: process.env.AWS_REGION || 'us-east-1',
};
if (process.env.SQS_ENDPOINT) {
  sqsConfig.endpoint = process.env.SQS_ENDPOINT;
  sqsConfig.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'local',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'local',
  };
}
const sqsClient = new SQSClient(sqsConfig);

async function poll() {
  if (!QUEUE_URL) {
    console.warn('SQS_INVOICE_QUEUE_URL not set — worker idle');
    return;
  }

  while (true) {
    try {
      const response = await sqsClient.send(
        new ReceiveMessageCommand({
          QueueUrl: QUEUE_URL,
          MaxNumberOfMessages: 5,
          WaitTimeSeconds: 20,
        })
      );

      if (!response.Messages || response.Messages.length === 0) continue;

      for (const message of response.Messages) {
        try {
          const payload = JSON.parse(message.Body);
          await processInvoiceJob(payload);

          // Delete message only after successful processing
          await sqsClient.send(
            new DeleteMessageCommand({
              QueueUrl: QUEUE_URL,
              ReceiptHandle: message.ReceiptHandle,
            })
          );
        } catch (err) {
          console.error('Failed to process invoice message:', err.message);
          // Message will become visible again after visibility timeout
        }
      }
    } catch (err) {
      console.error('SQS poll error:', err.message);
      await new Promise((r) => setTimeout(r, 5000));
    }
  }
}

console.log('Invoice worker starting...');
poll().catch(console.error);
