-- Idempotent demo seed: update emails to demo.com, fix ticket status, add comment
UPDATE users SET email = 'landlord@demo.com', name = 'Demo Landlord' WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE users SET email = 'tenant@demo.com', name = 'Demo Tenant' WHERE id = '22222222-2222-2222-2222-222222222222';

UPDATE tickets SET status = 'in_progress' WHERE id = '77777777-7777-7777-7777-777777777777';

-- Add 1 ticket comment if not exists
INSERT INTO ticket_comments (id, ticket_id, author_user_id, body, created_at)
SELECT 'cccccccc-cccc-cccc-cccc-cccccccccccc', '66666666-6666-6666-6666-666666666666', '22222222-2222-2222-2222-222222222222', 'Plumber came by, will fix tomorrow.', now()
WHERE NOT EXISTS (SELECT 1 FROM ticket_comments WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc');
