-- Phase B3: Unit membership table
CREATE TABLE unit_members (
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (unit_id, user_id)
);

CREATE INDEX idx_unit_members_account_unit ON unit_members(account_id, unit_id);
CREATE INDEX idx_unit_members_account_user ON unit_members(account_id, user_id);
