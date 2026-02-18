-- Phase B4: Tenant invites for units
CREATE TABLE tenant_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invite_code TEXT NOT NULL,
    invite_url_token TEXT NOT NULL,
    contact_type TEXT NOT NULL,
    contact_value TEXT NOT NULL,
    invited_role TEXT NOT NULL DEFAULT 'tenant',
    status TEXT NOT NULL DEFAULT 'pending',
    expires_at TIMESTAMPTZ NOT NULL,
    accepted_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    accepted_at TIMESTAMPTZ,
    canceled_at TIMESTAMPTZ,
    last_sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_tenant_invites_invite_code ON tenant_invites(invite_code);
CREATE UNIQUE INDEX idx_tenant_invites_invite_url_token ON tenant_invites(invite_url_token);
CREATE INDEX idx_tenant_invites_account_unit ON tenant_invites(account_id, unit_id);
CREATE INDEX idx_tenant_invites_account_status ON tenant_invites(account_id, status);
