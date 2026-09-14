import { env } from '../config/env.js';
import { AppError } from '../types/api.js';

type Token = { access_token: string; expires_in: number };
type CheckoutResult = { id: string; redirectUrl: string };
export type CheckoutIntent = {
  id: string;
  metadata?: Record<string, string>;
  order?: { id?: string | number };
};
type CheckoutInput = { amountCents: number; itemName: string; containsDonation: boolean; payer?: { firstName: string; lastName: string; email: string }; metadata: Record<string, string>; terms?: { amount: number; date: string }[] };
export class HelloAssoClient {
  private token?: { value: string; expiresAt: number };
  get configured(): boolean { return Boolean(env.HELLOASSO_CLIENT_ID && env.HELLOASSO_CLIENT_SECRET && env.HELLOASSO_ORGANIZATION_SLUG); }
  async createCheckout(input: CheckoutInput): Promise<CheckoutResult> {
    if (!this.configured) throw new AppError(503, 'payments_unavailable', 'HelloAsso is not configured.');
    const base = env.HELLOASSO_ENVIRONMENT === 'production' ? 'https://api.helloasso.com' : 'https://api.helloasso-sandbox.com';
    const response = await fetch(`${base}/v5/organizations/${encodeURIComponent(env.HELLOASSO_ORGANIZATION_SLUG!)}/checkout-intents`, { method: 'POST', headers: { authorization: `Bearer ${await this.accessToken(base)}`, 'content-type': 'application/json', accept: 'application/json' }, body: JSON.stringify({ totalAmount: input.amountCents + (input.terms?.reduce((sum, term) => sum + term.amount, 0) ?? 0), initialAmount: input.amountCents, itemName: input.itemName, backUrl: `${env.MOBILE_RETURN_URL}?result=cancelled`, errorUrl: `${env.MOBILE_RETURN_URL}?result=error`, returnUrl: `${env.MOBILE_RETURN_URL}?result=returned`, containsDonation: input.containsDonation, payer: input.payer, metadata: input.metadata, terms: input.terms }) });
    if (!response.ok) throw new AppError(502, 'payment_provider_error', 'HelloAsso could not create the checkout intent.');
    const data = await response.json() as { id: string; redirectUrl: string };
    return { id: data.id, redirectUrl: data.redirectUrl };
  }
  async getCheckoutIntent(checkoutIntentId: string): Promise<CheckoutIntent> {
    if (!this.configured) throw new AppError(503, 'payments_unavailable', 'HelloAsso is not configured.');
    const base = env.HELLOASSO_ENVIRONMENT === 'production' ? 'https://api.helloasso.com' : 'https://api.helloasso-sandbox.com';
    const response = await fetch(`${base}/v5/organizations/${encodeURIComponent(env.HELLOASSO_ORGANIZATION_SLUG!)}/checkout-intents/${encodeURIComponent(checkoutIntentId)}`, {
      headers: { authorization: `Bearer ${await this.accessToken(base)}`, accept: 'application/json' },
    });
    if (!response.ok) throw new AppError(502, 'payment_provider_error', 'HelloAsso could not verify the checkout intent.');
    return await response.json() as CheckoutIntent;
  }
  async accessToken(base: string): Promise<string> { if (this.token && this.token.expiresAt > Date.now() + 60000) return this.token.value; const body = new URLSearchParams({ grant_type: 'client_credentials', client_id: env.HELLOASSO_CLIENT_ID!, client_secret: env.HELLOASSO_CLIENT_SECRET! }); const response = await fetch(`${base}/oauth2/token`, { method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded' }, body }); if (!response.ok) throw new AppError(502, 'payment_provider_auth_error', 'HelloAsso authentication failed.'); const token = await response.json() as Token; this.token = { value: token.access_token, expiresAt: Date.now() + token.expires_in * 1000 }; return this.token.value; }
}
