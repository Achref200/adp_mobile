import 'dotenv/config';
import { z } from 'zod';
// Fallback secrets for serverless/demo deployments where no env is configured.
// For real production deployments, always set these explicitly in the environment.
const DEV_FALLBACK_SECRET = 'adp-dev-only-fallback-secret-change-me-0001';
const envSchema = z.object({
    PORT: z.coerce.number().int().positive().default(8080),
    DATABASE_URL: z.string().url().default('postgres://localhost:5432/adp'),
    ALLOW_SQLITE_FALLBACK: z.coerce.boolean().default(true),
    JWT_ACCESS_SECRET: z.string().min(32).default(DEV_FALLBACK_SECRET),
    JWT_REFRESH_SECRET: z.string().min(32).default(DEV_FALLBACK_SECRET + 'a'),
    EPASS_SIGNING_SECRET: z.string().min(32).default(DEV_FALLBACK_SECRET + 'b'),
    APP_ORIGIN: z.string().default('*'),
    MOBILE_RETURN_URL: z.string().url().default('https://app.djerbaproject.fr/payment-return'),
    HELLOASSO_ENVIRONMENT: z.enum(['sandbox', 'production']).default('sandbox'),
    HELLOASSO_CLIENT_ID: z.string().optional(),
    HELLOASSO_CLIENT_SECRET: z.string().optional(),
    HELLOASSO_WEBHOOK_SECRET: z.string().optional(),
    HELLOASSO_ORGANIZATION_SLUG: z.string().optional(),
    HELLOASSO_DONATION_FORM_URL: z.string().url().optional(),
});
export const env = envSchema.parse(process.env);
