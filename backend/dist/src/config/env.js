import 'dotenv/config';
import { z } from 'zod';
const envSchema = z.object({
    PORT: z.coerce.number().int().positive().default(8080),
    DATABASE_URL: z.string().url(),
    JWT_ACCESS_SECRET: z.string().min(32),
    JWT_REFRESH_SECRET: z.string().min(32),
    EPASS_SIGNING_SECRET: z.string().min(32),
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
