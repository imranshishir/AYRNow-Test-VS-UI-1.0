-- Phase B9: Ledger core - immutable charges, payments, refunds, balances
CREATE TABLE ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    lease_id UUID REFERENCES leases(id) ON DELETE SET NULL,
    type TEXT NOT NULL,
    subtype TEXT NOT NULL,
    amount_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    direction TEXT NOT NULL,
    occurred_on DATE NOT NULL,
    memo TEXT,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ledger_entries_account_unit_occurred ON ledger_entries(account_id, unit_id, occurred_on);
CREATE INDEX idx_ledger_entries_account_lease_occurred ON ledger_entries(account_id, lease_id, occurred_on);
CREATE INDEX idx_ledger_entries_account_type_occurred ON ledger_entries(account_id, type, occurred_on);

CREATE TABLE idempotency_keys (
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    endpoint TEXT NOT NULL,
    request_hash TEXT NOT NULL,
    response_json JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, key, endpoint)
);

CREATE INDEX idx_idempotency_keys_account_created ON idempotency_keys(account_id, created_at);
