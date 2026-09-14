import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth.js';
import { UserRepository } from '../repositories/user-repository.js';
import { TokenService } from '../services/token-service.js';
import { AppError } from '../types/api.js';
const registerSchema = z.object({ firstName: z.string().min(1).max(100), lastName: z.string().min(1).max(100), email: z.string().email(), country: z.string().min(2).max(100), password: z.string().min(12).max(128) });
const loginSchema = z.object({ email: z.string().email(), password: z.string().min(1) });
const refreshSchema = z.object({ refreshToken: z.string().min(20) });
const forgotSchema = z.object({ email: z.string().email() });
export async function authRoutes(app) {
    const users = new UserRepository();
    const tokens = new TokenService();
    app.post('/register', async (request, reply) => { const input = registerSchema.parse(request.body); if (await users.findByEmail(input.email))
        throw new AppError(409, 'email_taken', 'An account already exists for this email.'); const user = await users.create({ ...input, passwordHash: await bcrypt.hash(input.password, 12) }); return reply.code(201).send({ user, accessToken: tokens.issueAccessToken(user.id), refreshToken: await tokens.issueRefreshToken(user.id) }); });
    app.post('/login', async (request) => { const input = loginSchema.parse(request.body); const user = await users.findByEmail(input.email); if (!user || !await bcrypt.compare(input.password, user.passwordHash))
        throw new AppError(401, 'invalid_credentials', 'Email or password is incorrect.'); const { passwordHash: _, ...safeUser } = user; return { user: safeUser, accessToken: tokens.issueAccessToken(user.id), refreshToken: await tokens.issueRefreshToken(user.id) }; });
    app.post('/refresh', async (request) => { const { refreshToken } = refreshSchema.parse(request.body); const next = await tokens.rotate(refreshToken); if (!next)
        throw new AppError(401, 'invalid_session', 'Your session has expired.'); return next; });
    app.post('/forgot-password', async (request, reply) => { forgotSchema.parse(request.body); /* Queue a reset email only if the account exists; response must not reveal that fact. */ /* Queue a reset email only if the account exists; response must not reveal that fact. */ return reply.code(202).send({ accepted: true }); });
    app.post('/logout', { preHandler: requireAuth }, async () => ({ ok: true }));
}
