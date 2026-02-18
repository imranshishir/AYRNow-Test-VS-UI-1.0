-- Phase B5: Maintenance tickets and comments
CREATE TABLE maintenance_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    priority TEXT NOT NULL DEFAULT 'medium',
    assigned_contractor_id UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_maintenance_tickets_account_property ON maintenance_tickets(account_id, property_id);
CREATE INDEX idx_maintenance_tickets_account_unit ON maintenance_tickets(account_id, unit_id);
CREATE INDEX idx_maintenance_tickets_account_status ON maintenance_tickets(account_id, status);
CREATE INDEX idx_maintenance_tickets_account_created_by ON maintenance_tickets(account_id, created_by_user_id);

CREATE TABLE ticket_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    ticket_id UUID NOT NULL REFERENCES maintenance_tickets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ticket_comments_account_ticket ON ticket_comments(account_id, ticket_id);
CREATE INDEX idx_ticket_comments_account_user ON ticket_comments(account_id, user_id);
