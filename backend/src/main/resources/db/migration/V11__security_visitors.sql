-- Phase B8: Security guard visitor log + property settings
CREATE TABLE property_security_settings (
    property_id UUID PRIMARY KEY REFERENCES properties(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    approval_required BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_property_security_settings_account_property ON property_security_settings(account_id, property_id);

CREATE TABLE visitor_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    visitor_name TEXT NOT NULL,
    visitor_phone TEXT,
    purpose TEXT,
    status TEXT NOT NULL DEFAULT 'logged',
    approved_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    denied_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    denied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_visitor_entries_account_property_created ON visitor_entries(account_id, property_id, created_at DESC);
CREATE INDEX idx_visitor_entries_account_unit_created ON visitor_entries(account_id, unit_id, created_at DESC);
CREATE INDEX idx_visitor_entries_account_status_created ON visitor_entries(account_id, status, created_at DESC);
