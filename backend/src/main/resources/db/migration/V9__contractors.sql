-- Phase B6: Contractors and assignments
CREATE TABLE contractors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    company TEXT,
    specialty TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    linked_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_contractors_account_status ON contractors(account_id, status);
CREATE INDEX idx_contractors_account_name ON contractors(account_id, name);

CREATE TABLE contractor_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    contractor_id UUID NOT NULL REFERENCES contractors(id) ON DELETE CASCADE,
    ticket_id UUID NOT NULL REFERENCES maintenance_tickets(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'assigned',
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    accepted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    notes TEXT
);

-- Only one non-canceled assignment per ticket
CREATE UNIQUE INDEX idx_contractor_assignments_ticket_active
    ON contractor_assignments(ticket_id) WHERE status != 'canceled';

CREATE INDEX idx_contractor_assignments_account_contractor ON contractor_assignments(account_id, contractor_id);
CREATE INDEX idx_contractor_assignments_account_status ON contractor_assignments(account_id, status);
