-- =============================================================================
-- AYRNOW DEV: Reset and full 4-role seed (local profile only)
-- Loaded from classpath:db-local only when local profile adds that location.
-- TRUNCATES all domain data – prod never loads db-local.
--
-- Users (all passwords: Password123!):
--   landlord@demo.com  – landlord role
--   tenant@demo.com    – tenant role
--   contractor@demo.com – contractor role
--   guard@demo.com     – security_guard role
-- =============================================================================

-- -----------------------------------------------------------------------------
-- A) TRUNCATE all domain tables (FK-safe via CASCADE from accounts)
-- -----------------------------------------------------------------------------
TRUNCATE accounts RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- B) Stable UUIDs for cross-reference
-- -----------------------------------------------------------------------------
-- Account:    11111111-1111-1111-1111-111111111111  "Harlem Rd Property Management"
-- Landlord:   22222222-2222-2222-2222-222222222222  landlord@demo.com
-- Tenant:     33333333-3333-3333-3333-333333333333  tenant@demo.com
-- Contractor: 44444444-4444-4444-4444-444444444401  contractor@demo.com
-- Guard:      44444444-4444-4444-4444-444444444402  guard@demo.com
-- Property:   55555555-5555-5555-5555-555555555555  "Harlem Rd Apartments"
-- Unit A101:  66666666-6666-6666-6666-666666666601  occupied
-- Unit A102:  66666666-6666-6666-6666-666666666602  vacant
-- Lease:      77777777-7777-7777-7777-777777777777  active
-- Ticket:     88888888-8888-8888-8888-888888888888  open (leaking faucet)
-- Contractor: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa  linked contractor record

-- BCrypt hash for "Password123!" ($2a$10 rounds, Java-compatible)
-- Verified: bcrypt.checkpw(b'Password123!', hash) == True

-- -----------------------------------------------------------------------------
-- 1. Account
-- -----------------------------------------------------------------------------
INSERT INTO accounts (id, name, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Harlem Rd Property Management', now());

-- -----------------------------------------------------------------------------
-- 2. Users (4 roles)
-- -----------------------------------------------------------------------------
INSERT INTO users (id, account_id, email, display_name, password_hash, is_active, created_at) VALUES
    ('22222222-2222-2222-2222-222222222222',
     '11111111-1111-1111-1111-111111111111',
     'landlord@demo.com',
     'James Williams',
     '$2a$10$h6ifEqPQyDFs08k5gkyuf.YIXErTK2h42LcBgZIu7FsdtVwQk4DWO',
     true, now()),

    ('33333333-3333-3333-3333-333333333333',
     '11111111-1111-1111-1111-111111111111',
     'tenant@demo.com',
     'Alex Johnson',
     '$2a$10$h6ifEqPQyDFs08k5gkyuf.YIXErTK2h42LcBgZIu7FsdtVwQk4DWO',
     true, now()),

    ('44444444-4444-4444-4444-444444444401',
     '11111111-1111-1111-1111-111111111111',
     'contractor@demo.com',
     'Mike Rivera',
     '$2a$10$h6ifEqPQyDFs08k5gkyuf.YIXErTK2h42LcBgZIu7FsdtVwQk4DWO',
     true, now()),

    ('44444444-4444-4444-4444-444444444402',
     '11111111-1111-1111-1111-111111111111',
     'guard@demo.com',
     'Sam Patel',
     '$2a$10$h6ifEqPQyDFs08k5gkyuf.YIXErTK2h42LcBgZIu7FsdtVwQk4DWO',
     true, now());

-- -----------------------------------------------------------------------------
-- 3. User roles
-- -----------------------------------------------------------------------------
INSERT INTO user_roles (user_id, role) VALUES
    ('22222222-2222-2222-2222-222222222222', 'landlord'),
    ('33333333-3333-3333-3333-333333333333', 'tenant'),
    ('44444444-4444-4444-4444-444444444401', 'contractor'),
    ('44444444-4444-4444-4444-444444444402', 'security_guard');

-- -----------------------------------------------------------------------------
-- 4. Property (1 property owned by landlord's account)
-- -----------------------------------------------------------------------------
INSERT INTO properties (id, account_id, name, address1, city, state, postal_code, created_at) VALUES
    ('55555555-5555-5555-5555-555555555555',
     '11111111-1111-1111-1111-111111111111',
     'Harlem Rd Apartments',
     '742 Harlem Rd',
     'Buffalo',
     'NY',
     '14215',
     now());

-- -----------------------------------------------------------------------------
-- 5. Units (A101 occupied, A102 vacant)
-- -----------------------------------------------------------------------------
INSERT INTO units (id, account_id, property_id, unit_label, status, created_at) VALUES
    ('66666666-6666-6666-6666-666666666601',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     'A101', 'occupied', now()),

    ('66666666-6666-6666-6666-666666666602',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     'A102', 'vacant', now());

-- -----------------------------------------------------------------------------
-- 6. Lease (tenant on Unit A101, active)
-- -----------------------------------------------------------------------------
INSERT INTO leases (id, account_id, unit_id, status, start_date, end_date, tenant_user_id, created_at) VALUES
    ('77777777-7777-7777-7777-777777777777',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     'active',
     '2025-03-01',
     '2026-02-28',
     '33333333-3333-3333-3333-333333333333',
     now());

-- -----------------------------------------------------------------------------
-- 7. Lease tenants + unit members (link tenant to lease and unit)
-- -----------------------------------------------------------------------------
INSERT INTO lease_tenants (account_id, lease_id, user_id, added_at) VALUES
    ('11111111-1111-1111-1111-111111111111',
     '77777777-7777-7777-7777-777777777777',
     '33333333-3333-3333-3333-333333333333',
     now());

INSERT INTO unit_members (account_id, unit_id, user_id, role, added_at) VALUES
    ('11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     '33333333-3333-3333-3333-333333333333',
     'tenant', now());

-- -----------------------------------------------------------------------------
-- 8. Tenant invite (one pending, from landlord to a new person)
-- -----------------------------------------------------------------------------
INSERT INTO tenant_invites (id, account_id, unit_id, created_by_user_id, invite_code, invite_url_token, contact_type, contact_value, invited_role, status, expires_at, created_at) VALUES
    ('aaa11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666602',
     '22222222-2222-2222-2222-222222222222',
     'INV-DEMO-001',
     'demo-invite-token-001',
     'email',
     'newrenter@example.com',
     'tenant',
     'pending',
     now() + interval '7 days',
     now());

-- -----------------------------------------------------------------------------
-- 9. Maintenance ticket (open, created by tenant on Unit A101)
-- -----------------------------------------------------------------------------
INSERT INTO maintenance_tickets (id, account_id, property_id, unit_id, created_by_user_id, title, description, status, priority, created_at, updated_at) VALUES
    ('88888888-8888-8888-8888-888888888888',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     '66666666-6666-6666-6666-666666666601',
     '33333333-3333-3333-3333-333333333333',
     'Leaking kitchen faucet',
     'The kitchen faucet in Unit A101 has been dripping steadily. Water pools under the sink cabinet. Needs plumber.',
     'in_progress',
     'high',
     now() - interval '3 days',
     now());

-- Ticket comment from tenant
INSERT INTO ticket_comments (id, account_id, ticket_id, user_id, body, created_at) VALUES
    ('bbb11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     '88888888-8888-8888-8888-888888888888',
     '33333333-3333-3333-3333-333333333333',
     'Water is getting worse, please send someone soon.',
     now() - interval '2 days');

-- Ticket comment from landlord
INSERT INTO ticket_comments (id, account_id, ticket_id, user_id, body, created_at) VALUES
    ('bbb22222-2222-2222-2222-222222222222',
     '11111111-1111-1111-1111-111111111111',
     '88888888-8888-8888-8888-888888888888',
     '22222222-2222-2222-2222-222222222222',
     'Contractor assigned. Mike Rivera from Rivera Plumbing will be there tomorrow morning.',
     now() - interval '1 day');

-- -----------------------------------------------------------------------------
-- 10. Contractor record (linked to contractor user)
-- -----------------------------------------------------------------------------
INSERT INTO contractors (id, account_id, name, email, phone, company, specialty, status, linked_user_id, created_at, updated_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     '11111111-1111-1111-1111-111111111111',
     'Mike Rivera',
     'contractor@demo.com',
     '555-0100',
     'Rivera Plumbing LLC',
     'plumbing',
     'active',
     '44444444-4444-4444-4444-444444444401',
     now(), now());

-- -----------------------------------------------------------------------------
-- 11. Contractor assignment (in_progress, linked to ticket)
-- -----------------------------------------------------------------------------
INSERT INTO contractor_assignments (id, account_id, contractor_id, ticket_id, status, assigned_at, accepted_at, notes) VALUES
    ('ccc11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     '88888888-8888-8888-8888-888888888888',
     'in_progress',
     now() - interval '1 day',
     now() - interval '12 hours',
     'Scheduled for morning visit. Bringing replacement faucet kit.');

UPDATE maintenance_tickets
   SET assigned_contractor_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
 WHERE id = '88888888-8888-8888-8888-888888888888';

-- -----------------------------------------------------------------------------
-- 12. Community post (landlord announcement)
-- -----------------------------------------------------------------------------
INSERT INTO community_posts (id, account_id, property_id, author_user_id, title, body, kind, created_at, updated_at) VALUES
    ('ddd11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     '22222222-2222-2222-2222-222222222222',
     'Water Maintenance Notice',
     'City water maintenance scheduled for March 5, 2:00 PM – 5:00 PM. Please store water in advance.',
     'announcement',
     now() - interval '2 hours',
     now() - interval '2 hours');

INSERT INTO post_comments (id, account_id, post_id, user_id, body, created_at) VALUES
    ('ddd22222-2222-2222-2222-222222222222',
     '11111111-1111-1111-1111-111111111111',
     'ddd11111-1111-1111-1111-111111111111',
     '33333333-3333-3333-3333-333333333333',
     'Thanks for the heads up!',
     now() - interval '1 hour');

INSERT INTO post_reactions (account_id, post_id, user_id, reaction, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111',
     'ddd11111-1111-1111-1111-111111111111',
     '33333333-3333-3333-3333-333333333333',
     'like', now());

-- Notification for tenant about the post
INSERT INTO notifications (id, account_id, user_id, type, ref_id, title, body, created_at) VALUES
    ('eee11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     '33333333-3333-3333-3333-333333333333',
     'post',
     'ddd11111-1111-1111-1111-111111111111',
     'New announcement: Water Maintenance Notice',
     'City water maintenance scheduled for March 5.',
     now() - interval '2 hours');

-- -----------------------------------------------------------------------------
-- 13. Security: property settings + visitor entries (guard flow)
-- -----------------------------------------------------------------------------
INSERT INTO property_security_settings (property_id, account_id, approval_required, created_at, updated_at) VALUES
    ('55555555-5555-5555-5555-555555555555',
     '11111111-1111-1111-1111-111111111111',
     true, now(), now());

-- Pending visitor (guard needs to approve)
INSERT INTO visitor_entries (id, account_id, property_id, unit_id, created_by_user_id, visitor_name, visitor_phone, purpose, status, created_at) VALUES
    ('fff11111-1111-1111-1111-111111111111',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     '66666666-6666-6666-6666-666666666601',
     '33333333-3333-3333-3333-333333333333',
     'Maria Garcia',
     '555-0200',
     'Package delivery from Amazon',
     'pending',
     now());

-- Completed entry log (approved by guard yesterday)
INSERT INTO visitor_entries (id, account_id, property_id, unit_id, created_by_user_id, visitor_name, visitor_phone, purpose, status, approved_by_user_id, approved_at, created_at) VALUES
    ('fff22222-2222-2222-2222-222222222222',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     '66666666-6666-6666-6666-666666666601',
     '33333333-3333-3333-3333-333333333333',
     'Tom Builder',
     '555-0300',
     'Furniture delivery',
     'approved',
     '44444444-4444-4444-4444-444444444402',
     now() - interval '1 day',
     now() - interval '1 day');

-- -----------------------------------------------------------------------------
-- 14. Ledger: rent charge (Feb, paid) + rent charge (Mar, due)
-- -----------------------------------------------------------------------------
-- Feb rent: $1500 charge + $1500 payment = paid
INSERT INTO ledger_entries (id, account_id, unit_id, lease_id, type, subtype, amount_cents, currency, direction, occurred_on, memo, created_by_user_id, created_at) VALUES
    ('11111111-2222-3333-4444-555555550001',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     '77777777-7777-7777-7777-777777777777',
     'charge', 'rent', 150000, 'USD', 'debit',
     '2026-02-01',
     'February 2026 rent',
     '22222222-2222-2222-2222-222222222222',
     now() - interval '27 days');

INSERT INTO ledger_entries (id, account_id, unit_id, lease_id, type, subtype, amount_cents, currency, direction, occurred_on, memo, created_by_user_id, created_at) VALUES
    ('11111111-2222-3333-4444-555555550002',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     '77777777-7777-7777-7777-777777777777',
     'payment', 'rent_payment', 150000, 'USD', 'credit',
     '2026-02-03',
     'February 2026 rent paid via bank transfer',
     '33333333-3333-3333-3333-333333333333',
     now() - interval '24 days');

-- Mar rent: $1500 charge (upcoming, no payment yet)
INSERT INTO ledger_entries (id, account_id, unit_id, lease_id, type, subtype, amount_cents, currency, direction, occurred_on, memo, created_by_user_id, created_at) VALUES
    ('11111111-2222-3333-4444-555555550003',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     '77777777-7777-7777-7777-777777777777',
     'charge', 'rent', 150000, 'USD', 'debit',
     '2026-03-01',
     'March 2026 rent',
     '22222222-2222-2222-2222-222222222222',
     now());

-- -----------------------------------------------------------------------------
-- 15. Payment record (for the completed Feb payment)
-- -----------------------------------------------------------------------------
INSERT INTO payment_records (id, account_id, unit_id, lease_id, stripe_checkout_session_id, stripe_payment_intent_id, amount_cents, currency, status, created_by_user_id, created_at, updated_at) VALUES
    ('22222222-3333-4444-5555-666666660001',
     '11111111-1111-1111-1111-111111111111',
     '66666666-6666-6666-6666-666666666601',
     '77777777-7777-7777-7777-777777777777',
     'cs_demo_feb_001',
     'pi_demo_feb_001',
     150000, 'USD', 'succeeded',
     '33333333-3333-3333-3333-333333333333',
     now() - interval '24 days',
     now() - interval '24 days');

INSERT INTO webhook_events (id, account_id, stripe_event_id, type, received_at, processed_at, status) VALUES
    ('33333333-4444-5555-6666-777777770001',
     '11111111-1111-1111-1111-111111111111',
     'evt_demo_feb_001',
     'checkout.session.completed',
     now() - interval '24 days',
     now() - interval '24 days',
     'processed');

-- -----------------------------------------------------------------------------
-- 16. Tenant profile + review (for transfer feature)
-- -----------------------------------------------------------------------------
INSERT INTO tenant_profiles (user_id, created_at, updated_at, about, phone, email, last_known_address) VALUES
    ('33333333-3333-3333-3333-333333333333',
     now(), now(),
     'Reliable long-term tenant. Non-smoker, no pets. Always pays rent on time.',
     '555-0400',
     'tenant@demo.com',
     '742 Harlem Rd, Unit A101, Buffalo, NY 14215');

INSERT INTO tenant_reviews (id, tenant_user_id, from_account_id, from_property_id, from_unit_id, rating, review_text, created_at) VALUES
    ('44444444-5555-6666-7777-888888880001',
     '33333333-3333-3333-3333-333333333333',
     '11111111-1111-1111-1111-111111111111',
     '55555555-5555-5555-5555-555555555555',
     '66666666-6666-6666-6666-666666666601',
     5,
     'Excellent tenant. Kept the unit in perfect condition and always communicated promptly.',
     now() - interval '30 days');

-- Tenant profile export + approved transfer request
INSERT INTO tenant_profile_exports (id, tenant_user_id, share_token, status, created_at, expires_at) VALUES
    ('55555555-6666-7777-8888-999999990001',
     '33333333-3333-3333-3333-333333333333',
     'share-demo-token-001',
     'active',
     now(),
     now() + interval '30 days');

INSERT INTO tenant_transfer_requests (id, export_id, requesting_account_id, requesting_user_id, status, requested_at, decided_at, decision_by_user_id) VALUES
    ('66666666-7777-8888-9999-aaaaaaaaa001',
     '55555555-6666-7777-8888-999999990001',
     '11111111-1111-1111-1111-111111111111',
     '22222222-2222-2222-2222-222222222222',
     'approved',
     now() - interval '7 days',
     now() - interval '5 days',
     '22222222-2222-2222-2222-222222222222');
