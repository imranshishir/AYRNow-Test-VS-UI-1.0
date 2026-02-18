-- Phase B11: Tenant transfer profile
CREATE TABLE tenant_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    about TEXT,
    phone TEXT,
    email TEXT,
    last_known_address TEXT
);

CREATE TABLE tenant_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    from_account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    from_property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    from_unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tenant_reviews_tenant_created ON tenant_reviews(tenant_user_id, created_at DESC);

CREATE TABLE tenant_profile_exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    share_token TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_tenant_profile_exports_tenant_created ON tenant_profile_exports(tenant_user_id, created_at DESC);
CREATE UNIQUE INDEX idx_tenant_profile_exports_share_token ON tenant_profile_exports(share_token);

CREATE TABLE tenant_transfer_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    export_id UUID NOT NULL REFERENCES tenant_profile_exports(id) ON DELETE CASCADE,
    requesting_account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    requesting_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending',
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_at TIMESTAMPTZ,
    decision_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_tenant_transfer_requests_export_requested ON tenant_transfer_requests(export_id, requested_at DESC);
CREATE INDEX idx_tenant_transfer_requests_requesting_requested ON tenant_transfer_requests(requesting_account_id, requested_at DESC);
CREATE UNIQUE INDEX idx_tenant_transfer_requests_export_account_pending ON tenant_transfer_requests(export_id, requesting_account_id) WHERE status = 'pending';
