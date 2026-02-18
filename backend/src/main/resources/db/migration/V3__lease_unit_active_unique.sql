-- Enforce at most one active lease per unit
CREATE UNIQUE INDEX idx_leases_unit_active_unique ON leases(unit_id) WHERE status = 'active';
