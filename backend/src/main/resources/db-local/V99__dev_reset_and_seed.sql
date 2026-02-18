-- =============================================================================
-- AYRNOW DEV: Reset and minimal seed (local profile only)
-- Loaded from classpath:db-local only when local profile adds that location.
-- TRUNCATES all domain data – prod never loads db-local.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- A) TRUNCATE all domain tables (FK-safe via CASCADE from accounts)
-- -----------------------------------------------------------------------------
TRUNCATE accounts RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- B) Seed data – minimal correlated dataset for every backend module
-- -----------------------------------------------------------------------------

-- B0: Account
INSERT INTO accounts (id, name, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'AYRNOW Dev Account', now());

-- B0: Users (landlord + tenant)
-- bcrypt hash for "password" (10 rounds). test@test.com added in V100.
INSERT INTO users (id, account_id, email, display_name, password_hash, is_active, created_at) VALUES
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'landlord@dev.com', 'Dev Landlord', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', true, now()),
    ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'tenant@dev.com', 'Dev Tenant', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', true, now());

-- B0: User roles
INSERT INTO user_roles (user_id, role) VALUES
    ('22222222-2222-2222-2222-222222222222', 'landlord'),
    ('33333333-3333-3333-3333-333333333333', 'tenant');

-- B0: Property
INSERT INTO properties (id, account_id, name, address1, city, state, postal_code, created_at) VALUES
    ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Dev Property', '123 Dev St', 'Dev City', 'DV', '00000', now());

-- B0: Unit (occupied)
INSERT INTO units (id, account_id, property_id, unit_label, status, created_at) VALUES
    ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '101', 'occupied', now());

-- B0: Lease (active)
INSERT INTO leases (id, account_id, unit_id, status, start_date, end_date, tenant_user_id, created_at) VALUES
    ('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'active', '2024-01-01', '2025-12-31', '33333333-3333-3333-3333-333333333333', now());

-- B3: Lease tenants
INSERT INTO lease_tenants (account_id, lease_id, user_id, added_at) VALUES
    ('11111111-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', now());

-- B3: Unit member (tenant linked to unit)
INSERT INTO unit_members (account_id, unit_id, user_id, role, added_at) VALUES
    ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'tenant', now());

-- B4: Tenant invite (one pending)
INSERT INTO tenant_invites (id, account_id, unit_id, created_by_user_id, invite_code, invite_url_token, contact_type, contact_value, invited_role, status, expires_at, created_at) VALUES
    ('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'INV-DEV-001', 'dev-invite-token-001', 'email', 'invitee@dev.com', 'tenant', 'pending', now() + interval '7 days', now());

-- B5: Maintenance ticket (one open)
INSERT INTO maintenance_tickets (id, account_id, property_id, unit_id, created_by_user_id, title, description, status, priority, created_at, updated_at) VALUES
    ('88888888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'Leaking faucet', 'Kitchen sink drips', 'open', 'medium', now(), now());

-- B5: Ticket comment
INSERT INTO ticket_comments (id, account_id, ticket_id, user_id, body, created_at) VALUES
    ('99999999-9999-9999-9999-999999999999', '11111111-1111-1111-1111-111111111111', '88888888-8888-8888-8888-888888888888', '33333333-3333-3333-3333-333333333333', 'Please fix soon', now());

-- B6: Contractor
INSERT INTO contractors (id, account_id, name, email, phone, company, specialty, status, created_at, updated_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Dev Plumbing Co', 'plumber@dev.com', '555-0100', 'Dev Plumbing', 'plumbing', 'active', now(), now());

-- B6: Contractor assignment (assigned to ticket)
INSERT INTO contractor_assignments (id, account_id, contractor_id, ticket_id, status, assigned_at, notes) VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '88888888-8888-8888-8888-888888888888', 'assigned', now(), 'Scheduled for next week');

-- Update ticket with assigned contractor (no FK; nullable column)
UPDATE maintenance_tickets SET assigned_contractor_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' WHERE id = '88888888-8888-8888-8888-888888888888';

-- B7: Community post (one announcement)
INSERT INTO community_posts (id, account_id, property_id, author_user_id, title, body, kind, created_at, updated_at) VALUES
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Welcome', 'Welcome to Dev Property. Please keep common areas clean.', 'announcement', now(), now());

-- B7: Post comment
INSERT INTO post_comments (id, account_id, post_id, user_id, body, created_at) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'Thanks!', now());

-- B7: Post reaction
INSERT INTO post_reactions (account_id, post_id, user_id, reaction, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'like', now());

-- B7: Notification
INSERT INTO notifications (id, account_id, user_id, type, ref_id, title, body, created_at) VALUES
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'post', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'New announcement', 'Welcome to Dev Property.', now());

-- B8: Property security settings (for visitor approval flow)
INSERT INTO property_security_settings (property_id, account_id, approval_required, created_at, updated_at) VALUES
    ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', true, now(), now());

-- B8: Visitor entry (one pending)
INSERT INTO visitor_entries (id, account_id, property_id, unit_id, created_by_user_id, visitor_name, visitor_phone, purpose, status, created_at) VALUES
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'John Visitor', '555-0200', 'Delivery', 'pending', now());

-- B9: Ledger – one charge (rent 1000.00), one payment (1000.00), balance = 0
INSERT INTO ledger_entries (id, account_id, unit_id, lease_id, type, subtype, amount_cents, currency, direction, occurred_on, memo, created_by_user_id, created_at) VALUES
    ('11111111-2222-3333-4444-555555555501', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '66666666-6666-6666-6666-666666666666', 'charge', 'rent', 100000, 'USD', 'debit', CURRENT_DATE, 'January rent', '22222222-2222-2222-2222-222222222222', now()),
    ('11111111-2222-3333-4444-555555555502', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '66666666-6666-6666-6666-666666666666', 'payment', 'rent_payment', 100000, 'USD', 'credit', CURRENT_DATE, 'January rent paid', '33333333-3333-3333-3333-333333333333', now());

-- B10: Payment record (matches ledger payment – for Stripe webhook simulation)
INSERT INTO payment_records (id, account_id, unit_id, lease_id, stripe_checkout_session_id, stripe_payment_intent_id, amount_cents, currency, status, created_by_user_id, created_at, updated_at) VALUES
    ('22222222-3333-4444-5555-666666666601', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '66666666-6666-6666-6666-666666666666', 'cs_dev_test_001', 'pi_dev_test_001', 100000, 'USD', 'succeeded', '33333333-3333-3333-3333-333333333333', now(), now());

-- B10: Webhook event (for Stripe webhook simulation)
INSERT INTO webhook_events (id, account_id, stripe_event_id, type, received_at, processed_at, status) VALUES
    ('33333333-4444-5555-6666-777777777701', '11111111-1111-1111-1111-111111111111', 'evt_dev_test_001', 'checkout.session.completed', now(), now(), 'processed');

-- B11: Tenant profile
INSERT INTO tenant_profiles (user_id, created_at, updated_at, about, phone, email, last_known_address) VALUES
    ('33333333-3333-3333-3333-333333333333', now(), now(), 'Reliable tenant', '555-0300', 'tenant@dev.com', '123 Dev St, Unit 101');

-- B11: Tenant review (one approved/positive review)
INSERT INTO tenant_reviews (id, tenant_user_id, from_account_id, from_property_id, from_unit_id, rating, review_text, created_at) VALUES
    ('44444444-5555-6666-7777-888888888801', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555', 5, 'Great tenant, always paid on time.', now());

-- B11: Tenant profile export + transfer request (approved)
INSERT INTO tenant_profile_exports (id, tenant_user_id, share_token, status, created_at, expires_at) VALUES
    ('55555555-6666-7777-8888-999999999901', '33333333-3333-3333-3333-333333333333', 'share-dev-token-001', 'active', now(), now() + interval '30 days');

INSERT INTO tenant_transfer_requests (id, export_id, requesting_account_id, requesting_user_id, status, requested_at, decided_at, decision_by_user_id) VALUES
    ('66666666-7777-8888-9999-aaaaaaaaaa01', '55555555-6666-7777-8888-999999999901', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'approved', now() - interval '1 day', now(), '22222222-2222-2222-2222-222222222222');
