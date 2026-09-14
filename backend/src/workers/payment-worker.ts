import { env } from '../config/env.js';
import { PaymentReconciliationService } from '../services/payment-reconciliation.js';

const worker = new PaymentReconciliationService();

async function run(): Promise<void> {
  try {
    const processed = await worker.reconcilePendingWebhooks();
    if (processed > 0) console.info(`Payment reconciliation inspected ${processed} event(s).`);
  } catch (error) {
    console.error('Payment reconciliation cycle failed.', error);
  }
}

await run();
setInterval(run, 60_000);
console.info(`ADP payment worker started in ${env.HELLOASSO_ENVIRONMENT} mode.`);
