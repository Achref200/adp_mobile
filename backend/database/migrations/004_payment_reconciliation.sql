ALTER TABLE memberships
  ADD COLUMN IF NOT EXISTS helloasso_checkout_intent_id VARCHAR(128) UNIQUE,
  ADD COLUMN IF NOT EXISTS helloasso_order_id VARCHAR(128) UNIQUE;

ALTER TABLE donations
  ADD COLUMN IF NOT EXISTS anonymous BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS memberships_checkout_intent_idx
  ON memberships(helloasso_checkout_intent_id)
  WHERE helloasso_checkout_intent_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS donations_checkout_intent_idx
  ON donations(helloasso_checkout_intent_id)
  WHERE helloasso_checkout_intent_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS helloasso_webhook_pending_idx
  ON helloasso_webhook_events(received_at)
  WHERE processed_at IS NULL;
