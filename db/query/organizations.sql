-- name: GetOrganization :one
SELECT * from organizations
WHERE id = $1 LIMIT 1;

-- name: SetOrganizationAgent :exec
UPDATE organizations
SET default_agent_id = $1
WHERE id = $2;

-- name: CreateOrganization :one
INSERT INTO organizations (
  name, type
) VALUES (
  $1, $2
) RETURNING *;
