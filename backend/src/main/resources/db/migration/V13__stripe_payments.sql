-- Phase B10: Stripe payments integration
CREATE TABLE payment_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    lease_id UUID REFERENCES leases(id) ON DELETE SET NULL,
    stripe_checkout_session_id TEXT UNIQUE,
    stripe_payment_intent_id TEXT UNIQUE,
    amount_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    status TEXT NOT NULL,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_payment_records_account_unit_created ON payment_records(account_id, unit_id, created_at DESC);
CREATE INDEX idx_payment_records_account_lease_created ON payment_records(account_id, lease_id, created_at DESC);
CREATE UNIQUE INDEX idx_payment_records_stripe_pi ON payment_records(stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;
CREATE UNIQUE INDEX idx_payment_records_stripe_session ON payment_records(stripe_checkout_session_id) WHERE stripe_checkout_session_id IS NOT NULL;

CREATE TABLE webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    stripe_event_id TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'received',
    error TEXT
);

CREATE INDEX idx_webhook_events_stripe_event_id ON webhook_events(stripe_event_id);
