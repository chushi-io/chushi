CREATE TABLE access_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    name character varying(64),
    token character varying(512),
    user_id uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    last_seen timestamp with time zone,
    deleted_at timestamp with time zone,
    expires_at timestamp with time zone
);

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT fk_access_tokens_users FOREIGN KEY (user_id) REFERENCES users(id);

CREATE UNIQUE INDEX access_tokens_idx_token ON access_tokens (token);
CREATE INDEX access_tokens_idx_user_name ON access_tokens (user_id, name);