import cors from '@fastify/cors';
import Fastify from 'fastify';
import rawBody from 'fastify-raw-body';
import { ZodError } from 'zod';
import { env } from './config/env.js';
import { authRoutes } from './routes/auth-routes.js';
import { apiRoutes } from './routes/api-routes.js';
import { paymentRoutes } from './routes/payment-routes.js';
import { databaseHealth } from './config/database.js';
import { AppError } from './types/api.js';
export function buildApp() {
    // QR e-pass payloads (ADP1.<uuid>.<uuid>.<date>.<sig>) exceed the default
    // 100-char param limit; raise it so /e-pass/verify/:payload accepts real passes.
    const app = Fastify({ logger: true, maxParamLength: 500 });
    app.register(cors, { origin: env.APP_ORIGIN === '*' ? true : env.APP_ORIGIN });
    app.register(rawBody, { global: false, encoding: 'utf8', runFirst: true });
    app.get('/health', async (_request, reply) => {
        try {
            return { ok: true, database: await databaseHealth() };
        }
        catch {
            return reply.status(503).send({ ok: false, database: 'unavailable' });
        }
    });
    app.register(authRoutes, { prefix: '/v1/auth' });
    app.register(apiRoutes, { prefix: '/v1' });
    app.register(paymentRoutes, { prefix: '/v1' });
    app.setErrorHandler((error, _request, reply) => {
        if (error instanceof ZodError)
            return reply.status(400).send({ error: { code: 'validation_error', message: 'Invalid request.', details: error.flatten() } });
        if (error instanceof AppError)
            return reply.status(error.statusCode).send({ error: { code: error.code, message: error.message, details: error.details } });
        app.log.error(error);
        return reply.status(500).send({ error: { code: 'internal_error', message: 'An unexpected error occurred.' } });
    });
    return app;
}
