CREATE TABLE configuration_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    workspace_id uuid,
    source character varying(64),
    speculative boolean,
    status character varying(64),
    upload_url character varying(512),
    provisional boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY configuration_versions
    ADD CONSTRAINT fk_configuration_versions_workspaces FOREIGN KEY (workspace_id) REFERENCES workspaces(id);

