import { AppError } from '../types/api.js';
import { TokenService } from '../services/token-service.js';
const tokens = new TokenService();
export async function requireAuth(request) {
    const value = request.headers.authorization;
    const token = value?.startsWith('Bearer ') ? value.slice(7) : undefined;
    const userId = token ? tokens.verifyAccessToken(token) : null;
    if (!userId)
        throw new AppError(401, 'unauthorized', 'Authentication is required.');
    request.userId = userId;
}
