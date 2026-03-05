CREATE TABLE community_posts (
    id UUID PRIMARY KEY,
    scope_type TEXT NOT NULL,
    scope_id UUID,
    author_user_id UUID NOT NULL REFERENCES users(id),
    author_name TEXT,
    author_role TEXT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'info',
    audience TEXT NOT NULL DEFAULT 'all',
    comment_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE community_comments (
    id UUID PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES community_posts(id),
    author_user_id UUID NOT NULL REFERENCES users(id),
    author_name TEXT,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE transfer_requests (
    id UUID PRIMARY KEY,
    tenant_user_id UUID NOT NULL REFERENCES users(id),
    target_email_or_code TEXT NOT NULL,
    note TEXT,
    status TEXT NOT NULL,
    landlord_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_at TIMESTAMPTZ
);

CREATE TABLE household_members (
    id UUID PRIMARY KEY,
    unit_id UUID NOT NULL REFERENCES units(id),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL,
    status TEXT NOT NULL,
    invite_code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(unit_id, email)
);

CREATE INDEX idx_community_posts_scope ON community_posts(scope_type, scope_id);
CREATE INDEX idx_community_comments_post ON community_comments(post_id);
CREATE INDEX idx_transfer_requests_tenant ON transfer_requests(tenant_user_id);
CREATE INDEX idx_household_members_unit ON household_members(unit_id);
