import { createPublicKey } from 'node:crypto';
import jwt from 'jsonwebtoken';
const GOOGLE_JWKS_URL = 'https://www.googleapis.com/oauth2/v3/certs';
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];
const CLOCK_TOLERANCE_SECONDS = 60;
let cachedKey = null;
let cachedKeyFetchedAt = 0;
const KEY_CACHE_TTL_MS = 60 * 60 * 1000;
async function fetchGoogleKeys() {
    const response = await fetch(GOOGLE_JWKS_URL, { signal: AbortSignal.timeout(5000) });
    if (!response.ok)
        throw new Error(`Google JWKS request failed: ${response.status}`);
    const { keys } = (await response.json());
    const map = new Map();
    for (const k of keys) {
        map.set(k.kid, createPublicKey({ key: k, format: 'jwk' }).export({ type: 'spki', format: 'pem' }).toString());
    }
    return map;
}
async function getGoogleKeys() {
    if (cachedKey && Date.now() - cachedKeyFetchedAt < KEY_CACHE_TTL_MS) {
        // Cache holds one entry; refresh wholesale after TTL.
        return new Map([[cachedKey.kid, cachedKey.key]]);
    }
    const keys = await fetchGoogleKeys();
    const first = keys.entries().next();
    if (first.done)
        throw new Error('Google JWKS is empty.');
    cachedKey = { kid: first.value[0], key: first.value[1] };
    cachedKeyFetchedAt = Date.now();
    return keys;
}
/** Verifies a Google-issued idToken and returns the verified profile. Throws when invalid. */
export async function verifyGoogleIdToken(idToken) {
    const decodedHeader = jwt.decode(idToken, { complete: true });
    if (!decodedHeader || typeof decodedHeader === 'string') {
        throw new Error('Malformed Google idToken.');
    }
    const kid = decodedHeader.header.kid;
    const keys = await getGoogleKeys();
    const pem = keys.get(kid ?? '') ?? keys.values().next().value;
    if (!pem)
        throw new Error('No matching Google signing key.');
    const claims = jwt.verify(idToken, pem, {
        algorithms: ['RS256'],
        issuer: GOOGLE_ISSUERS,
        clockTolerance: CLOCK_TOLERANCE_SECONDS,
    });
    if (!claims.sub || !claims.email)
        throw new Error('Google idToken is missing required claims.');
    return {
        sub: claims.sub,
        email: claims.email.toLowerCase(),
        emailVerified: claims.email_verified ?? false,
        firstName: claims.given_name ?? '',
        lastName: claims.family_name ?? '',
        locale: claims.locale,
    };
}
