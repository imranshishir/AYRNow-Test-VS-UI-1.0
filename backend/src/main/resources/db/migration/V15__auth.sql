-- Phase B12: JWT Auth - extend users, add refresh tokens

-- Extend users table for auth (password_hash, is_active)
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- Existing users from seed may have null password_hash; they remain for DevAuth only.

-- Refresh tokens for token rotation
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ NULL,
    replaced_by UUID NULL REFERENCES refresh_tokens(id) ON DELETE SET NULL
);

CREATE UNIQUE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_account_user ON refresh_tokens(account_id, user_id);
