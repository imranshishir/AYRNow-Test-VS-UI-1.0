INSERT INTO users (id, email, name, role, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'landlord@example.com', 'Demo Landlord', 'landlord', now()),
    ('22222222-2222-2222-2222-222222222222', 'tenant@example.com', 'Demo Tenant', 'tenant', now());

INSERT INTO properties (id, owner_user_id, name, address, created_at) VALUES
    ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Harlem Rd Apartments', '123 Harlem Rd', now());

INSERT INTO units (id, property_id, label, created_at) VALUES
    ('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'Unit 1A', now());

INSERT INTO memberships (id, unit_id, user_id, role, created_at) VALUES
    ('55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'tenant', now());

INSERT INTO tickets (id, property_id, unit_id, created_by_user_id, title, description, status, priority, created_at) VALUES
    ('66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Leaking sink', 'Kitchen sink leaks', 'Open', 'High', now()),
    ('77777777-7777-7777-7777-777777777777', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'AC not cooling', null, 'Approved', 'Med', now() - interval '2 days');

INSERT INTO notifications (id, target_user_id, type, title, body, route, is_read, created_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'announcement', 'Community update', 'New building newsletter available.', '/community', false, now() - interval '2 hours'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'transferRequest', 'New transfer request', 'A tenant requested a profile transfer.', '/L-45', true, now() - interval '5 hours');
