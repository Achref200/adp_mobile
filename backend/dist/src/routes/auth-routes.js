import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth.js';
import { UserRepository } from '../repositories/user-repository.js';
import { TokenService } from '../services/token-service.js';
import { verifyGoogleIdToken } from '../services/google-verify.js';
import { AppError } from '../types/api.js';
const registerSchema = z.object({ firstName: z.string().min(1).max(100), lastName: z.string().min(1).max(100), email: z.string().email(), country: z.string().min(2).max(100), password: z.string().min(12).max(128) });
const loginSchema = z.object({ email: z.string().email(), password: z.string().min(1) });
const refreshSchema = z.object({ refreshToken: z.string().min(20) });
const forgotSchema = z.object({ email: z.string().email() });
const googleSchema = z.object({ idToken: z.string().min(20).max(4096) });
export async function authRoutes(app) {
    const users = new UserRepository();
    const tokens = new TokenService();
    app.post('/register', async (request, reply) => { const input = registerSchema.parse(request.body); if (await users.findByEmail(input.email))
        throw new AppError(409, 'email_taken', 'An account already exists for this email.'); const user = await users.create({ ...input, passwordHash: await bcrypt.hash(input.password, 12) }); return reply.code(201).send({ user, accessToken: tokens.issueAccessToken(user.id), refreshToken: await tokens.issueRefreshToken(user.id) }); });
    app.post('/login', async (request) => { const input = loginSchema.parse(request.body); const user = await users.findByEmail(input.email); if (!user || !await bcrypt.compare(input.password, user.passwordHash))
        throw new AppError(401, 'invalid_credentials', 'Email or password is incorrect.'); const { passwordHash: _, ...safeUser } = user; return { user: safeUser, accessToken: tokens.issueAccessToken(user.id), refreshToken: await tokens.issueRefreshToken(user.id) }; });
    // Google Sign-In: verifies the platform idToken, links or provisions the account, issues an ADP session.
    app.post('/google', async (request) => {
        const { idToken } = googleSchema.parse(request.body);
        const profile = await verifyGoogleIdToken(idToken);
        if (!profile.emailVerified)
            throw new AppError(401, 'google_email_unverified', 'Your Google account email is not verified.');
        let user = await users.findByGoogleSub(profile.sub);
        if (!user) {
            const byEmail = await users.findByEmail(profile.email);
            if (byEmail) {
                await users.linkGoogle(byEmail.id, profile.sub);
                user = byEmail;
            }
            else {
                const displayName = profile.firstName || profile.email.split('@')[0];
                user = await users.create({
                    firstName: displayName.slice(0, 100),
                    lastName: profile.lastName || '-',
                    email: profile.email,
                    country: '—',
                    passwordHash: await bcrypt.hash(`${profile.sub}:${profile.email}:${Date.now()}`, 12),
                    googleSub: profile.sub,
                });
            }
        }
        if (!user)
            throw new AppError(401, 'google_user_unavailable', 'Google account could not be linked.');
        // Explicit projection: never echo password material back to the client.
        const safeUser = { id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email, country: user.country, directoryVisible: user.directoryVisible };
        return { user: safeUser, accessToken: tokens.issueAccessToken(user.id), refreshToken: await tokens.issueRefreshToken(user.id) };
    });
    app.post('/refresh', async (request) => { const { refreshToken } = refreshSchema.parse(request.body); const next = await tokens.rotate(refreshToken); if (!next)
        throw new AppError(401, 'invalid_session', 'Your session has expired.'); return next; });
    app.post('/forgot-password', async (request, reply) => { forgotSchema.parse(request.body); /* Queue a reset email only if the account exists; response must not reveal that fact. */ /* Queue a reset email only if the account exists; response must not reveal that fact. */ return reply.code(202).send({ accepted: true }); });
    app.post('/logout', { preHandler: requireAuth }, async () => ({ ok: true }));
}
