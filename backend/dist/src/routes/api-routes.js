import { createHmac } from 'node:crypto';
import { z } from 'zod';
import { env } from '../config/env.js';
import { requireAuth } from '../middleware/auth.js';
import { ContentRepository } from '../repositories/content-repository.js';
import { EngagementRepository } from '../repositories/engagement-repository.js';
import { MemberRepository } from '../repositories/member-repository.js';
import { PrivacyRepository } from '../repositories/privacy-repository.js';
import { UserRepository } from '../repositories/user-repository.js';
import { AppError } from '../types/api.js';
const membershipInput = z.object({ plan: z.enum(['individual', 'family', 'diaspora', 'benefactor']), amountCents: z.number().int().positive(), djerbaConnection: z.string().min(2).max(2000), motivation: z.string().max(4000).optional() });
const profileInput = z.object({ visible: z.boolean(), city: z.string().max(100).optional(), sector: z.string().max(120).optional(), skills: z.array(z.string().min(1).max(80)).max(20).optional() });
const connectionInput = z.object({ recipientId: z.string().uuid() });
const deviceInput = z.object({ token: z.string().min(20).max(255), platform: z.enum(['android', 'ios']), preferences: z.record(z.string(), z.boolean()) });
const consentInput = z.object({ purpose: z.enum(['directory_visibility', 'analytics', 'communications']), granted: z.boolean() });
export async function apiRoutes(app) {
    const content = new ContentRepository();
    const users = new UserRepository();
    const members = new MemberRepository();
    const engagement = new EngagementRepository();
    const privacy = new PrivacyRepository();
    app.get('/me', { preHandler: requireAuth }, async (request) => { const user = await users.findById(request.userId); if (!user)
        throw new AppError(404, 'user_not_found', 'User not found.'); return user; });
    app.get('/projects', async () => content.projects());
    app.get('/news', async () => content.rows('news'));
    app.get('/events', async () => content.rows('events'));
    app.get('/summit', async () => ({
        title: 'Djerba Diaspora Summit 2026',
        edition: '3ème Édition Internationale',
        dates: '18 - 20 Décembre 2026',
        location: 'Houmt Souk & Djerba Explore',
        attendeesCount: 420,
        isRegistered: true,
        tracks: [
            { id: 'trk-1', title: 'Tech, IA & Startups Diaspora', speaker: 'Tarek Bouzguenda', time: '18 Déc · 10:00' },
            { id: 'trk-2', title: 'Patrimoine & Post-UNESCO', speaker: 'Kamel Ghedamsi', time: '18 Déc · 14:30' },
            { id: 'trk-3', title: 'Transition Énergétique & Eau', speaker: 'Nadia Ben Youssef', time: '19 Déc · 09:30' },
            { id: 'trk-4', title: 'Entrepreneuriat Féminin & Artisanat', speaker: 'Amel Haddad', time: '19 Déc · 15:00' }
        ],
        speakers: [
            { name: 'Dr. Myriam Trabelsi', role: 'Présidente ADP & Médecin', topic: "Discours d'ouverture : L'île face aux défis du siècle" },
            { name: 'Tarek Bouzguenda', role: 'Managing Partner Diaspora Tech', topic: "Fonds d'amorçage 2M€ pour les projets insulaires" },
            { name: 'Kamel Ghedamsi', role: 'Architecte en chef UNESCO', topic: "Sauvegarder l'habitat vernaculaire de Djerba" },
            { name: 'Nadia Ben Youssef', role: 'VP Transition Écologique', topic: "Djerba 100% solaire : feuille de route 2030" }
        ],
        livePoll: {
            question: 'Quel projet prioritaire doit recevoir la bourse spéciale du Sommet 2026 ?',
            options: [
                { id: 'opt-1', label: 'Usine de dessalement solaire villageoise', votes: 142 },
                { id: 'opt-2', label: 'Incubateur numérique jeunesse de Midoun', votes: 189 },
                { id: 'opt-3', label: 'Restauration des mosquées fortifiées', votes: 98 }
            ],
            userVoted: 'opt-2'
        }
    }));
    app.get('/memberships/current', { preHandler: requireAuth }, async (request) => (await members.current(request.userId)) ?? { id: 'draft', status: 'draft', plan: 'none', expiresAt: null });
    app.post('/memberships', { preHandler: requireAuth }, async (request, reply) => { const body = membershipInput.parse(request.body); return reply.code(201).send(await members.submit(request.userId, body)); });
    app.get('/me/e-pass', { preHandler: requireAuth }, async (request) => { const membership = await members.current(request.userId); if (!membership || membership.status !== 'active' || !membership.expiresAt)
        throw new AppError(404, 'epass_unavailable', 'An active membership is required.'); const claims = `${membership.id}.${request.userId}.${membership.expiresAt}`; const signature = createHmac('sha256', env.EPASS_SIGNING_SECRET).update(claims).digest('base64url'); return { memberId: membership.id, status: membership.status, validUntil: membership.expiresAt, qrPayload: `ADP1.${claims}.${signature}` }; });
    app.get('/donations', { preHandler: requireAuth }, async (request) => engagement.donations(request.userId));
    app.get('/networking/profiles', { preHandler: requireAuth }, async (request) => engagement.directory(request.query));
    app.put('/networking/me', { preHandler: requireAuth }, async (request) => engagement.updateProfile(request.userId, profileInput.parse(request.body)));
    app.post('/networking/requests', { preHandler: requireAuth }, async (request, reply) => reply.code(201).send(await engagement.requestConnection(request.userId, connectionInput.parse(request.body).recipientId)));
    app.get('/notifications', { preHandler: requireAuth }, async (request) => engagement.notifications(request.userId));
    app.post('/devices', { preHandler: requireAuth }, async (request, reply) => reply.code(201).send(await engagement.registerDevice(request.userId, deviceInput.parse(request.body))));
    app.post('/privacy/consents', { preHandler: requireAuth }, async (request, reply) => reply.code(201).send(await privacy.recordConsent(request.userId, consentInput.parse(request.body))));
    app.get('/privacy/export', { preHandler: requireAuth }, async (request) => privacy.exportData(request.userId));
    app.post('/privacy/erasure-requests', { preHandler: requireAuth }, async (request, reply) => reply.code(202).send(await privacy.requestErasure(request.userId)));
}
