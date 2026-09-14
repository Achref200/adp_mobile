CREATE TABLE IF NOT EXISTS data_subject_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  request_type VARCHAR(32) NOT NULL CHECK (request_type IN ('export', 'erasure')),
  status VARCHAR(24) NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'in_progress', 'completed', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS data_subject_requests_user_idx
  ON data_subject_requests(user_id, created_at DESC);
