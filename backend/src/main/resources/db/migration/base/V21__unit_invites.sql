-- Unit invites for landlord -> tenant onboarding
CREATE TABLE IF NOT EXISTS unit_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_unit_invites_unit ON unit_invites(unit_id);
CREATE INDEX IF NOT EXISTS idx_unit_invites_token ON unit_invites(token);
