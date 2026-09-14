export type MembershipStatus = 'draft' | 'submitted' | 'paymentConfirmed' | 'pendingReview' | 'active' | 'rejected' | 'expired';
export type ApiUser = { id: string; firstName: string; lastName: string; email: string; country: string; directoryVisible: boolean };
export type ApiProject = { id: string; title: string; category: string; summary: string; progress: number; targetCents: number; raisedCents: number; location: string };
export class AppError extends Error { constructor(public readonly statusCode: number, public readonly code: string, message: string, public readonly details?: unknown) { super(message); } }
