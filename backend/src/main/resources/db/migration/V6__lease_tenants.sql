-- Phase B3: Lease tenants mapping table
CREATE TABLE lease_tenants (
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    lease_id UUID NOT NULL REFERENCES leases(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (lease_id, user_id)
);

CREATE INDEX idx_lease_tenants_account_lease ON lease_tenants(account_id, lease_id);
CREATE INDEX idx_lease_tenants_account_user ON lease_tenants(account_id, user_id);
