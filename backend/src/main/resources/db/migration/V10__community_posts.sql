-- Phase B7: Community posts, comments, reactions, notifications
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    author_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT,
    body TEXT NOT NULL,
    kind TEXT NOT NULL DEFAULT 'announcement',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_community_posts_account_created ON community_posts(account_id, created_at DESC);
CREATE INDEX idx_community_posts_account_property_created ON community_posts(account_id, property_id, created_at DESC);
CREATE INDEX idx_community_posts_account_unit_created ON community_posts(account_id, unit_id, created_at DESC);

CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_post_comments_account_post_created ON post_comments(account_id, post_id, created_at);

CREATE TABLE post_reactions (
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reaction TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (post_id, user_id)
);

CREATE INDEX idx_post_reactions_account_post ON post_reactions(account_id, post_id);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    ref_id UUID,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_account_user_created ON notifications(account_id, user_id, created_at DESC);
CREATE INDEX idx_notifications_account_user_read ON notifications(account_id, user_id, read_at);
