-- Dev seed data for local testing (valid UUIDs for curl headers)
INSERT INTO accounts (id, name, created_at) VALUES
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Dev Account', now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, account_id, email, display_name, created_at) VALUES
    ('bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'dev@ayrnow.local', 'Dev User', now())
ON CONFLICT (id) DO NOTHING;
