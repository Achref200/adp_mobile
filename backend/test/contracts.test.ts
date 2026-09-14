import assert from 'node:assert/strict';
import test from 'node:test';
import type { MembershipStatus } from '../src/types/api.js';

test('membership contract accepts the manual-review lifecycle', () => {
  const status: MembershipStatus = 'pendingReview';
  assert.equal(status, 'pendingReview');
});
