-- name: GetWorkspace :one
SELECT * FROM workspaces
WHERE id = $1 LIMIT 1;

-- name: ListWorkspaces :many
SELECT * FROM workspaces
WHERE organization_id = $1;

-- name: CreateWorkspace :one
INSERT INTO workspaces (
  name, allow_destroy, auto_apply, auto_destroy_at, execution_mode,
  vcs_source, vcs_branch, vcs_patterns, vcs_working_directory,
  version, organization_id, agent_id, drift_detection_enabled,
  drift_detection_schedule, vcs_connection_id
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
) RETURNING *;

-- name: LockWorkspace :exec
UPDATE workspaces SET
  locked = true,
  lock_at = $1,
  lock_by = $2,
  lock_id = $3
WHERE
  id = $4 and locked = true;
