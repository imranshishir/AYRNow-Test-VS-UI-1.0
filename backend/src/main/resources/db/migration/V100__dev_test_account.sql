-- Test account for local dev (test@test.com / test123). Safe everywhere: ON CONFLICT DO NOTHING.
-- BCrypt hash for "test123" (10 rounds).

INSERT INTO accounts (id, name, created_at)
VALUES ('11111111-1111-1111-1111-111111111111', 'AYRNOW Dev Account', now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, account_id, email, display_name, password_hash, is_active, created_at)
VALUES (
    '99999999-9999-9999-9999-999999999999',
    '11111111-1111-1111-1111-111111111111',
    'test@test.com',
    'Test User',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    true,
    now()
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO user_roles (user_id, role)
SELECT id, 'landlord' FROM users WHERE email = 'test@test.com'
ON CONFLICT (user_id, role) DO NOTHING;
