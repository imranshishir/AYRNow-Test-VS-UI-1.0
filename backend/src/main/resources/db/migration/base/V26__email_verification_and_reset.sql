-- Email verification and password reset (hashed tokens, expiry)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_token_hash TEXT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_token_expires_at TIMESTAMPTZ NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_hash TEXT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_expires_at TIMESTAMPTZ NULL;

-- Existing users (seed/demo) remain able to log in; only new signups need verification
UPDATE users SET email_verified = true;
