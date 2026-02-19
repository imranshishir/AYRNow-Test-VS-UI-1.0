-- DEV-only idempotent seed: demo users (landlord@demo.com, tenant@demo.com), second unit,
-- 1 community post + 1 comment, 1 household member + 1 invited, 1 pending transfer, 2 notifications.
-- Relies on V2/V4 for base users/property/unit1/membership; updates emails to demo.com if needed.

-- Ensure demo emails (V4 may have run; idempotent)
UPDATE users SET email = 'landlord@demo.com', name = 'Demo Landlord' WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE users SET email = 'tenant@demo.com', name = 'Demo Tenant' WHERE id = '22222222-2222-2222-2222-222222222222';

-- Second unit (property 33333333)
INSERT INTO units (id, property_id, label, created_at)
VALUES ('88888888-8888-8888-8888-888888888888', '33333333-3333-3333-3333-333333333333', 'Unit 2A', now())
ON CONFLICT (id) DO NOTHING;

-- 1 community post (scope: property)
INSERT INTO community_posts (id, scope_type, scope_id, author_user_id, author_name, author_role, title, body, priority, audience, comment_count, created_at)
VALUES (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  'property',
  '33333333-3333-3333-3333-333333333333',
  '11111111-1111-1111-1111-111111111111',
  'Demo Landlord',
  'landlord',
  'Welcome to the building',
  'Please keep common areas tidy. Contact management for issues.',
  'info',
  'all',
  1,
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 1 comment on that post
INSERT INTO community_comments (id, post_id, author_user_id, author_name, body, created_at)
VALUES (
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  '22222222-2222-2222-2222-222222222222',
  'Demo Tenant',
  'Thanks, will do!',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 1 household member (active) on unit 1
INSERT INTO household_members (id, unit_id, name, email, phone, role, status, invite_code, created_at)
VALUES (
  'ffffffff-ffff-ffff-ffff-ffffffffffff',
  '44444444-4444-4444-4444-444444444444',
  'Jane Doe',
  'jane@example.com',
  NULL,
  'member',
  'active',
  NULL,
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 1 invited household member (unit 1)
INSERT INTO household_members (id, unit_id, name, email, phone, role, status, invite_code, created_at)
VALUES (
  '12121212-1212-1212-1212-121212121212',
  '44444444-4444-4444-4444-444444444444',
  'Pending Invite',
  'invited@example.com',
  NULL,
  'member',
  'invited',
  'INVITE-DEV-001',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 1 pending transfer request (tenant 222 -> target)
INSERT INTO transfer_requests (id, tenant_user_id, target_email_or_code, note, status, landlord_message, created_at, decided_at)
VALUES (
  '13131313-1313-1313-1313-131313131313',
  '22222222-2222-2222-2222-222222222222',
  'newtenant@example.com',
  'Moving out end of month',
  'pending',
  NULL,
  now(),
  NULL
)
ON CONFLICT (id) DO NOTHING;

-- 2 notifications (for tenant)
INSERT INTO notifications (id, target_user_id, type, title, body, route, params, is_read, created_at)
VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 'announcement', 'Rent due', 'Rent due in 3 days.', '/payments', NULL, false, now()),
  ('14141414-1414-1414-1414-141414141414', '22222222-2222-2222-2222-222222222222', 'ticket', 'Ticket update', 'Your ticket was updated.', '/tickets', NULL, false, now() - interval '1 hour')
ON CONFLICT (id) DO NOTHING;
