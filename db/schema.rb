# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_08_013309) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "external_id"
    t.string "token"
    t.string "token_authable_type", null: false
    t.uuid "token_authable_id", null: false
    t.string "scopes"
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
    t.index ["token_authable_type", "token_authable_id"], name: "index_access_tokens_on_token_authable"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.string "status"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.string "api_secret"
    t.datetime "last_ping_at", precision: nil
    t.string "ip_address"
    t.index ["api_key"], name: "index_agents_on_api_key", unique: true
    t.index ["external_id"], name: "index_agents_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_agents_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_agents_on_organization_id"
  end

  create_table "applies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "execution_mode"
    t.string "status"
    t.string "logs_url"
    t.integer "resource_additions"
    t.integer "resource_changes"
    t.integer "resource_destructions"
    t.integer "resource_imports"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_applies_on_external_id", unique: true
    t.index ["organization_id"], name: "index_applies_on_organization_id"
  end

  create_table "configuration_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "workspace_id"
    t.uuid "organization_id"
    t.string "source"
    t.boolean "speculative"
    t.string "status"
    t.string "upload_url"
    t.boolean "provisional"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_queue_runs", default: false
    t.index ["external_id"], name: "index_configuration_versions_on_external_id", unique: true
    t.index ["organization_id"], name: "index_configuration_versions_on_organization_id"
    t.index ["workspace_id"], name: "index_configuration_versions_on_workspace_id"
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "resource_owner_type", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_grants"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id"
    t.uuid "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.string "resource_owner_type"
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_tokens"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.uuid "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_organization_users_on_external_id", unique: true
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "allow_auto_create_workspace", default: false
    t.string "organization_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.uuid "agent_id"
    t.index ["agent_id"], name: "index_organizations_on_agent_id"
    t.index ["external_id"], name: "index_organizations_on_external_id", unique: true
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "execution_mode"
    t.boolean "has_changes"
    t.integer "resource_additions"
    t.integer "resource_changes"
    t.integer "resource_destructions"
    t.integer "resource_imports"
    t.string "status"
    t.string "logs_url"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_plans_on_external_id", unique: true
    t.index ["organization_id"], name: "index_plans_on_organization_id"
  end

  create_table "policies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.string "description"
    t.string "type"
    t.string "query"
    t.string "enforcement_level"
    t.uuid "organization_id"
    t.uuid "policy_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_policies_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_policies_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_policies_on_organization_id"
    t.index ["policy_set_id"], name: "index_policies_on_policy_set_id"
  end

  create_table "policy_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.string "description"
    t.boolean "global"
    t.string "kind"
    t.boolean "overridable"
    t.string "vcs_repo_branch"
    t.string "vcs_repo_identifier"
    t.string "ingress_submodules"
    t.string "vcs_repo_oauth_token_id"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_policy_sets_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_policy_sets_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_policy_sets_on_organization_id"
  end

  create_table "provider_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "version"
    t.json "protocols"
    t.json "platforms"
    t.json "gpg_public_keys"
    t.datetime "published_at", precision: nil
    t.uuid "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id", "version"], name: "index_provider_versions_on_provider_id_and_version", unique: true
    t.index ["provider_id"], name: "index_provider_versions_on_provider_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "namespace"
    t.string "provider_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace", "provider_type"], name: "index_providers_on_namespace_and_provider_type", unique: true
  end

  create_table "registry_module_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "version"
    t.string "location"
    t.string "source"
    t.string "definition"
    t.json "root"
    t.json "submodules"
    t.integer "downloads"
    t.boolean "verified"
    t.datetime "published_at", precision: nil
    t.uuid "registry_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registry_module_id", "version"], name: "idx_on_registry_module_id_version_b4b67eee77", unique: true
    t.index ["registry_module_id"], name: "index_registry_module_versions_on_registry_module_id"
  end

  create_table "registry_modules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "owner"
    t.string "namespace"
    t.string "name"
    t.string "provider"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace", "name", "provider"], name: "index_registry_modules_on_namespace_and_name_and_provider", unique: true
  end

  create_table "run_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "category"
    t.string "name"
    t.string "url"
    t.string "hmac_key"
    t.boolean "enabled"
    t.string "description"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_run_tasks_on_external_id", unique: true
    t.index ["organization_id"], name: "index_run_tasks_on_organization_id"
  end

  create_table "runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "agent_id"
    t.boolean "has_changes"
    t.boolean "auto_apply"
    t.boolean "is_destroy"
    t.string "message"
    t.boolean "plan_only"
    t.string "source"
    t.string "status"
    t.string "trigger_reason"
    t.boolean "refresh"
    t.boolean "refresh_only"
    t.boolean "save_plan"
    t.uuid "configuration_version_id"
    t.uuid "workspace_id"
    t.uuid "plan_id"
    t.uuid "apply_id"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_runs_on_agent_id"
    t.index ["apply_id"], name: "index_runs_on_apply_id"
    t.index ["configuration_version_id"], name: "index_runs_on_configuration_version_id"
    t.index ["external_id"], name: "index_runs_on_external_id", unique: true
    t.index ["organization_id"], name: "index_runs_on_organization_id"
    t.index ["plan_id"], name: "index_runs_on_plan_id"
    t.index ["workspace_id"], name: "index_runs_on_workspace_id"
  end

  create_table "state_version_outputs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.boolean "sensitive"
    t.string "type"
    t.text "value"
    t.uuid "state_version_id"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_state_version_outputs_on_external_id", unique: true
    t.index ["organization_id"], name: "index_state_version_outputs_on_organization_id"
    t.index ["state_version_id"], name: "index_state_version_outputs_on_state_version_id"
  end

  create_table "state_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.integer "size"
    t.string "hosted_state_download_url"
    t.string "hosted_state_upload_url"
    t.string "hosted_json_state_download_url"
    t.string "hosted_json_state_upload_url"
    t.string "status"
    t.boolean "intermediate"
    t.json "modules"
    t.json "providers"
    t.json "resources"
    t.boolean "resources_processed"
    t.integer "serial"
    t.integer "state_version"
    t.string "tofu_version"
    t.string "vcs_commit_url"
    t.string "vcs_commit_sha"
    t.uuid "workspace_id"
    t.uuid "run_id"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_state_versions_on_external_id", unique: true
    t.index ["organization_id"], name: "index_state_versions_on_organization_id"
    t.index ["run_id"], name: "index_state_versions_on_run_id"
    t.index ["workspace_id"], name: "index_state_versions_on_workspace_id"
  end

  create_table "taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tag_id"
    t.string "taggable_type"
    t.uuid "taggable_id"
    t.string "tagger_type"
    t.uuid "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "task_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "stage"
    t.string "status"
    t.uuid "run_id"
    t.uuid "run_task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_task_stages_on_external_id", unique: true
    t.index ["run_id"], name: "index_task_stages_on_run_id"
    t.index ["run_task_id"], name: "index_task_stages_on_run_task_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_id"], name: "index_users_on_external_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "variable_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.string "name"
    t.string "description"
    t.boolean "auto_attach"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_variable_sets_on_external_id", unique: true
    t.index ["organization_id"], name: "index_variable_sets_on_organization_id"
  end

  create_table "variables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "variable_type"
    t.string "name"
    t.string "value"
    t.string "description"
    t.boolean "sensitive"
    t.uuid "organization_id"
    t.uuid "workspace_id"
    t.uuid "variable_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_variables_on_external_id", unique: true
    t.index ["organization_id"], name: "index_variables_on_organization_id"
    t.index ["variable_set_id"], name: "index_variables_on_variable_set_id"
    t.index ["workspace_id"], name: "index_variables_on_workspace_id"
  end

  create_table "vcs_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.string "provider"
    t.string "github_type"
    t.string "github_personal_access_token"
    t.string "github_application_id"
    t.string "github_application_secret"
    t.string "github_oauth_application_id"
    t.string "github_oauth_application_secret"
    t.uuid "organization_id"
    t.string "webhook_id"
    t.string "webhook_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "github_installation_id"
    t.index ["external_id"], name: "index_vcs_connections_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_vcs_connections_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_vcs_connections_on_organization_id"
  end

  create_table "workspace_resources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.string "name"
    t.string "module"
    t.string "provider"
    t.string "provider_type"
    t.uuid "state_version_id"
    t.uuid "organization_id"
    t.string "name_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_workspace_resources_on_organization_id"
    t.index ["state_version_id"], name: "index_workspace_resources_on_state_version_id"
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.boolean "allow_destroy_plan"
    t.boolean "auto_apply"
    t.boolean "auto_apply_run_trigger"
    t.datetime "auto_destroy_at", precision: nil
    t.string "description"
    t.string "environment"
    t.string "execution_mode"
    t.boolean "file_triggers_enabled"
    t.boolean "global_remote_state"
    t.datetime "latest_change_at", precision: nil
    t.boolean "locked"
    t.string "name"
    t.boolean "operations"
    t.boolean "policy_check_failures"
    t.integer "resource_count"
    t.integer "run_failures"
    t.string "source"
    t.boolean "speculative_enabled"
    t.boolean "structured_run_output_enabled"
    t.string "tofu_version"
    t.json "trigger_prefixes"
    t.string "vcs_repo_identifier"
    t.string "working_directory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "vcs_connection_id"
    t.uuid "organization_id"
    t.uuid "agent_id"
    t.uuid "current_state_version_id"
    t.string "locked_by"
    t.datetime "locked_at", precision: nil
    t.string "lock_id"
    t.string "vcs_repo_branch"
    t.index ["agent_id"], name: "index_workspaces_on_agent_id"
    t.index ["current_state_version_id"], name: "index_workspaces_on_current_state_version_id"
    t.index ["external_id"], name: "index_workspaces_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_workspaces_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_workspaces_on_organization_id"
    t.index ["vcs_connection_id"], name: "index_workspaces_on_vcs_connection_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agents", "organizations"
  add_foreign_key "applies", "organizations"
  add_foreign_key "configuration_versions", "organizations"
  add_foreign_key "configuration_versions", "workspaces"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", on_delete: :cascade
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "organizations", "agents"
  add_foreign_key "plans", "organizations"
  add_foreign_key "policies", "organizations"
  add_foreign_key "policies", "policy_sets"
  add_foreign_key "policy_sets", "organizations"
  add_foreign_key "provider_versions", "providers"
  add_foreign_key "registry_module_versions", "registry_modules"
  add_foreign_key "run_tasks", "organizations"
  add_foreign_key "runs", "agents"
  add_foreign_key "runs", "applies"
  add_foreign_key "runs", "configuration_versions"
  add_foreign_key "runs", "organizations"
  add_foreign_key "runs", "plans"
  add_foreign_key "runs", "workspaces"
  add_foreign_key "state_version_outputs", "organizations"
  add_foreign_key "state_version_outputs", "state_versions"
  add_foreign_key "state_versions", "organizations"
  add_foreign_key "state_versions", "runs"
  add_foreign_key "state_versions", "workspaces"
  add_foreign_key "taggings", "tags"
  add_foreign_key "task_stages", "run_tasks"
  add_foreign_key "task_stages", "runs"
  add_foreign_key "variable_sets", "organizations"
  add_foreign_key "variables", "organizations"
  add_foreign_key "variables", "variable_sets"
  add_foreign_key "variables", "workspaces"
  add_foreign_key "vcs_connections", "organizations"
  add_foreign_key "workspace_resources", "organizations"
  add_foreign_key "workspace_resources", "state_versions"
  add_foreign_key "workspaces", "agents"
  add_foreign_key "workspaces", "organizations"
  add_foreign_key "workspaces", "state_versions", column: "current_state_version_id"
  add_foreign_key "workspaces", "vcs_connections"
end
