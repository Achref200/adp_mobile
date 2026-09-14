ALTER TABLE donations ADD COLUMN IF NOT EXISTS helloasso_checkout_intent_id VARCHAR(128) UNIQUE;
