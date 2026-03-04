-- Ledger entries (append-only)
CREATE TABLE ledger_entries (
    id UUID PRIMARY KEY,
    unit_id UUID NOT NULL REFERENCES units(id),
    entry_type TEXT NOT NULL,
    amount_cents INT NOT NULL,
    memo TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_memberships_user_id ON memberships(user_id);
CREATE INDEX idx_units_property_id ON units(property_id);
CREATE INDEX idx_tickets_property_id ON tickets(property_id);
CREATE INDEX idx_tickets_unit_id ON tickets(unit_id);
CREATE INDEX idx_notifications_target_user_id ON notifications(target_user_id);
CREATE INDEX idx_notifications_target_read ON notifications(target_user_id, is_read);
