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

ActiveRecord::Schema[7.1].define(version: 2024_11_10_021051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "external_id"
    t.string "token_authable_type", null: false
    t.uuid "token_authable_id", null: false
    t.string "scopes"
    t.datetime "expired_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description", limit: 255
    t.datetime "last_used_at", precision: nil
    t.string "token_encrypted"
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

  create_table "agent_pools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.boolean "organization_scoped", default: false
    t.index ["api_key"], name: "index_agent_pools_on_api_key", unique: true
    t.index ["external_id"], name: "index_agent_pools_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_agent_pools_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_agent_pools_on_organization_id"
  end

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "agent_pool_id"
    t.string "status"
    t.string "name"
    t.string "ip_address"
    t.datetime "last_ping_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_pool_id"], name: "index_agents_on_agent_pool_id"
    t.index ["external_id"], name: "index_agents_on_external_id", unique: true
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
    t.text "logs"
    t.index ["external_id"], name: "index_applies_on_external_id", unique: true
    t.index ["organization_id"], name: "index_applies_on_organization_id"
  end

  create_table "aws_networks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "cloud_provider_id"
    t.string "name"
    t.string "region"
    t.string "cidr_block"
    t.string "status"
    t.string "vpc_id"
    t.string "vpc_arn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cloud_provider_id"], name: "index_aws_networks_on_cloud_provider_id"
    t.index ["external_id"], name: "index_aws_networks_on_external_id", unique: true
  end

  create_table "cloud_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.string "cloud"
    t.string "name"
    t.string "display_name"
    t.string "credential_id"
    t.string "credential_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_cloud_providers_on_external_id", unique: true
    t.index ["organization_id"], name: "index_cloud_providers_on_organization_id"
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
    t.string "archive"
    t.index ["external_id"], name: "index_configuration_versions_on_external_id", unique: true
    t.index ["organization_id"], name: "index_configuration_versions_on_organization_id"
    t.index ["workspace_id"], name: "index_configuration_versions_on_workspace_id"
  end

  create_table "gpg_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.text "ascii_armor"
    t.string "namespace"
    t.string "key_id"
    t.string "source"
    t.string "source_url"
    t.string "trust_signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_gpg_keys_on_external_id", unique: true
  end

  create_table "jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "agent_id"
    t.uuid "workspace_id"
    t.uuid "run_id"
    t.string "locked_by"
    t.string "status"
    t.boolean "locked"
    t.integer "priority"
    t.string "operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "agent_pool_id"
    t.index ["agent_id"], name: "index_jobs_on_agent_id"
    t.index ["agent_pool_id"], name: "index_jobs_on_agent_pool_id"
    t.index ["organization_id"], name: "index_jobs_on_organization_id"
    t.index ["run_id"], name: "index_jobs_on_run_id"
    t.index ["workspace_id"], name: "index_jobs_on_workspace_id"
  end

  create_table "notification_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "workspace_id"
    t.string "destination_type"
    t.boolean "enabled"
    t.string "name"
    t.string "token"
    t.text "triggers", default: [], array: true
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_encrypted"
    t.index ["external_id"], name: "index_notification_configurations_on_external_id", unique: true
    t.index ["workspace_id", "name"], name: "index_notification_configurations_on_workspace_id_and_name", unique: true
    t.index ["workspace_id", "url"], name: "index_notification_configurations_on_workspace_id_and_url", unique: true
    t.index ["workspace_id"], name: "index_notification_configurations_on_workspace_id"
  end

  create_table "notification_delivery_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "notification_configuration_id"
    t.string "url"
    t.text "body"
    t.string "code"
    t.json "headers"
    t.datetime "sent_at", precision: nil
    t.boolean "successful"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_configuration_id"], name: "idx_on_notification_configuration_id_635bebe214"
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

  create_table "oauth_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "connect_path"
    t.string "service_provider"
    t.string "service_provider_display_name"
    t.string "name"
    t.string "auth_identifier"
    t.string "http_url"
    t.string "api_url"
    t.string "key"
    t.string "secret_encrypted"
    t.string "rsa_public_key"
    t.string "private_key_encrypted"
    t.string "oauth_token_string_encrypted"
    t.boolean "organization_scoped"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_identifier"], name: "index_oauth_clients_on_auth_identifier", unique: true
    t.index ["external_id"], name: "index_oauth_clients_on_external_id", unique: true
    t.index ["organization_id"], name: "index_oauth_clients_on_organization_id"
  end

  create_table "oauth_openid_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "oauth_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "service_provider_user"
    t.boolean "has_ssh_key"
    t.uuid "oauth_client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_oauth_tokens_on_external_id", unique: true
    t.index ["oauth_client_id"], name: "index_oauth_tokens_on_oauth_client_id"
  end

  create_table "openbao_clusters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.bigint "project_id"
    t.uuid "virtual_network_id"
    t.string "name"
    t.string "size"
    t.string "status"
    t.string "version"
    t.json "upgrade_strategy"
    t.json "metrics"
    t.json "allowed_ip_addresses"
    t.string "public_endpoint_url"
    t.string "private_endpoint_url"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_openbao_clusters_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_openbao_clusters_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_openbao_clusters_on_organization_id"
    t.index ["project_id"], name: "index_openbao_clusters_on_project_id"
    t.index ["virtual_network_id"], name: "index_openbao_clusters_on_virtual_network_id"
  end

  create_table "organization_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "user_id"
    t.string "email"
    t.string "external_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_organization_memberships_on_external_id", unique: true
    t.index ["organization_id", "email"], name: "index_organization_memberships_on_organization_id_and_email", unique: true
    t.index ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
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
    t.string "email", limit: 255
    t.string "default_execution_mode", limit: 255
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
    t.string "plan_file"
    t.string "plan_json_file"
    t.string "plan_structured_file"
    t.text "redacted_json"
    t.text "logs"
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
    t.string "policy"
    t.index ["external_id"], name: "index_policies_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_policies_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_policies_on_organization_id"
    t.index ["policy_set_id"], name: "index_policies_on_policy_set_id"
  end

  create_table "policy_evaluations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "policy_kind"
    t.string "policy_tool_version"
    t.json "result_count"
    t.json "status_timestamps"
    t.string "policy_set_id"
    t.uuid "task_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_policy_evaluations_on_external_id", unique: true
    t.index ["task_stage_id"], name: "index_policy_evaluations_on_task_stage_id"
  end

  create_table "policy_set_outcomes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.json "outcomes"
    t.string "error"
    t.boolean "overrideable"
    t.string "policy_set_name"
    t.string "policy_set_description"
    t.json "result_count"
    t.string "policy_tool_version"
    t.uuid "policy_evaluation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_policy_set_outcomes_on_external_id", unique: true
    t.index ["policy_evaluation_id"], name: "index_policy_set_outcomes_on_policy_evaluation_id"
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

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.string "description"
    t.integer "team_count"
    t.integer "workspace_count"
    t.string "auto_destroy_activity_duration"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_default", default: false
    t.index ["external_id"], name: "index_projects_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_projects_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "provider_version_platforms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "os"
    t.string "arch"
    t.string "shasum"
    t.string "filename"
    t.uuid "provider_version_id"
    t.text "binary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_provider_version_platforms_on_external_id", unique: true
    t.index ["provider_version_id"], name: "index_provider_version_platforms_on_provider_version_id"
  end

  create_table "provider_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "version"
    t.json "protocols"
    t.uuid "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key_id"
    t.boolean "shasums_uploaded"
    t.boolean "shasums_sig_uploaded"
    t.string "external_id"
    t.text "shasums"
    t.text "shasums_sig"
    t.index ["external_id"], name: "index_provider_versions_on_external_id", unique: true
    t.index ["provider_id", "version"], name: "index_provider_versions_on_provider_id_and_version", unique: true
    t.index ["provider_id"], name: "index_provider_versions_on_provider_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "namespace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.string "name"
    t.string "registry"
    t.uuid "organization_id"
    t.index ["external_id"], name: "index_providers_on_external_id", unique: true
    t.index ["organization_id"], name: "index_providers_on_organization_id"
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
    t.string "archive"
    t.string "status"
    t.string "external_id"
    t.index ["external_id"], name: "index_registry_module_versions_on_external_id", unique: true
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
    t.string "external_id"
    t.string "status"
    t.uuid "organization_id"
    t.index ["external_id"], name: "index_registry_modules_on_external_id", unique: true
    t.index ["namespace", "name", "provider"], name: "index_registry_modules_on_namespace_and_name_and_provider", unique: true
    t.index ["organization_id"], name: "index_registry_modules_on_organization_id"
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
    t.string "hmac_key_encrypted"
    t.index ["external_id"], name: "index_run_tasks_on_external_id", unique: true
    t.index ["organization_id"], name: "index_run_tasks_on_organization_id"
  end

  create_table "run_triggers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "workspace_id"
    t.uuid "sourceable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_run_triggers_on_external_id", unique: true
    t.index ["sourceable_id"], name: "index_run_triggers_on_sourceable_id"
    t.index ["workspace_id", "sourceable_id"], name: "index_run_triggers_on_workspace_id_and_sourceable_id", unique: true
    t.index ["workspace_id"], name: "index_run_triggers_on_workspace_id"
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
    t.json "target_addrs"
    t.json "refresh_addrs"
    t.boolean "allow_empty_apply"
    t.boolean "allow_config_generation"
    t.index ["agent_id"], name: "index_runs_on_agent_id"
    t.index ["apply_id"], name: "index_runs_on_apply_id"
    t.index ["configuration_version_id"], name: "index_runs_on_configuration_version_id"
    t.index ["external_id"], name: "index_runs_on_external_id", unique: true
    t.index ["organization_id"], name: "index_runs_on_organization_id"
    t.index ["plan_id"], name: "index_runs_on_plan_id"
    t.index ["workspace_id"], name: "index_runs_on_workspace_id"
  end

  create_table "ssh_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.string "name"
    t.text "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "private_key_encrypted"
    t.index ["external_id"], name: "index_ssh_keys_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_ssh_keys_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_ssh_keys_on_organization_id"
  end

  create_table "state_version_outputs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.boolean "sensitive"
    t.string "output_type"
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
    t.string "value_encrypted"
    t.string "state_file"
    t.string "state_json_file"
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

  create_table "task_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "task_stage_id"
    t.string "task_id"
    t.string "task_name"
    t.string "task_url"
    t.string "workspace_task_id"
    t.string "workspace_task_enforcement_level"
    t.string "message"
    t.string "status"
    t.json "status_timestamps"
    t.string "url"
    t.string "stage"
    t.boolean "is_speculative"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_task_results_on_external_id", unique: true
    t.index ["task_stage_id"], name: "index_task_results_on_task_stage_id"
  end

  create_table "task_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "stage"
    t.string "status"
    t.uuid "run_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_task_stages_on_external_id", unique: true
    t.index ["run_id"], name: "index_task_stages_on_run_id"
  end

  create_table "team_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "team_id"
    t.uuid "user_id"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_team_memberships_on_external_id", unique: true
    t.index ["organization_id"], name: "index_team_memberships_on_organization_id"
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "team_projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "project_id"
    t.uuid "team_id"
    t.string "external_id"
    t.string "access", default: "read"
    t.string "project_settings", default: "null"
    t.string "project_teams", default: "null"
    t.string "workspace_create", default: "null"
    t.string "workspace_move", default: "null"
    t.string "workspace_locking", default: "null"
    t.string "workspace_delete", default: "null"
    t.string "workspace_runs", default: "null"
    t.string "workspace_variables", default: "null"
    t.string "workspace_state_versions", default: "null"
    t.string "workspace_run_tasks", default: "null"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_team_projects_on_external_id", unique: true
    t.index ["organization_id"], name: "index_team_projects_on_organization_id"
    t.index ["project_id"], name: "index_team_projects_on_project_id"
    t.index ["team_id"], name: "index_team_projects_on_team_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.string "sso_team_id"
    t.integer "users_count"
    t.string "visibility"
    t.boolean "allow_member_token_management"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_teams_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_teams_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_teams_on_organization_id"
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
    t.boolean "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "global"
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
    t.string "value_encrypted"
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
    t.string "github_personal_access_token_encrypted"
    t.string "github_application_secret_encrypted"
    t.string "github_oauth_application_secret_encrypted"
    t.string "webhook_secret_encrypted"
    t.index ["external_id"], name: "index_vcs_connections_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_vcs_connections_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_vcs_connections_on_organization_id"
  end

  create_table "virtual_networks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.string "name"
    t.string "cloud"
    t.string "region"
    t.string "cidr_block"
    t.string "network_attachable_type"
    t.uuid "network_attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_virtual_networks_on_external_id", unique: true
    t.index ["network_attachable_type", "network_attachable_id"], name: "index_virtual_networks_on_network_attachable"
    t.index ["organization_id"], name: "index_virtual_networks_on_organization_id"
  end

  create_table "workspace_policy_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id"
    t.uuid "policy_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_set_id"], name: "index_workspace_policy_sets_on_policy_set_id"
    t.index ["workspace_id", "policy_set_id"], name: "index_workspace_policy_sets_on_workspace_id_and_policy_set_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_policy_sets_on_workspace_id"
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

  create_table "workspace_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "workspace_id"
    t.uuid "run_task_id"
    t.string "stage"
    t.text "stages", default: [], array: true
    t.string "enforcement_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_workspace_tasks_on_external_id", unique: true
    t.index ["run_task_id"], name: "index_workspace_tasks_on_run_task_id"
    t.index ["workspace_id", "run_task_id"], name: "index_workspace_tasks_on_workspace_id_and_run_task_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_tasks_on_workspace_id"
  end

  create_table "workspace_teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.uuid "organization_id"
    t.uuid "workspace_id"
    t.uuid "team_id"
    t.string "access", default: "null"
    t.string "runs", default: "null"
    t.string "variables", default: "null"
    t.string "state_versions", default: "null"
    t.boolean "workspace_locking", default: false
    t.boolean "run_tasks", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_workspace_teams_on_external_id", unique: true
    t.index ["organization_id"], name: "index_workspace_teams_on_organization_id"
    t.index ["team_id"], name: "index_workspace_teams_on_team_id"
    t.index ["workspace_id", "team_id"], name: "index_workspace_teams_on_workspace_id_and_team_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_teams_on_workspace_id"
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
    t.uuid "agent_pool_id"
    t.uuid "current_state_version_id"
    t.string "locked_by"
    t.datetime "locked_at", precision: nil
    t.string "lock_id"
    t.string "vcs_repo_branch"
    t.boolean "queue_all_runs"
    t.uuid "project_id"
    t.uuid "current_configuration_version_id"
    t.uuid "current_run_id"
    t.index ["agent_pool_id"], name: "index_workspaces_on_agent_id"
    t.index ["current_configuration_version_id"], name: "index_workspaces_on_current_configuration_version_id"
    t.index ["current_run_id"], name: "index_workspaces_on_current_run_id"
    t.index ["current_state_version_id"], name: "index_workspaces_on_current_state_version_id"
    t.index ["external_id"], name: "index_workspaces_on_external_id", unique: true
    t.index ["organization_id", "name"], name: "index_workspaces_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_workspaces_on_organization_id"
    t.index ["project_id"], name: "index_workspaces_on_project_id"
    t.index ["vcs_connection_id"], name: "index_workspaces_on_vcs_connection_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_pools", "organizations"
  add_foreign_key "agents", "agent_pools"
  add_foreign_key "applies", "organizations"
  add_foreign_key "aws_networks", "cloud_providers"
  add_foreign_key "cloud_providers", "organizations"
  add_foreign_key "configuration_versions", "organizations"
  add_foreign_key "configuration_versions", "workspaces"
  add_foreign_key "jobs", "agent_pools"
  add_foreign_key "jobs", "agent_pools", column: "agent_id"
  add_foreign_key "jobs", "organizations"
  add_foreign_key "jobs", "runs"
  add_foreign_key "jobs", "workspaces"
  add_foreign_key "notification_configurations", "workspaces"
  add_foreign_key "notification_delivery_responses", "notification_configurations"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_clients", "organizations"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", on_delete: :cascade
  add_foreign_key "oauth_tokens", "oauth_clients"
  add_foreign_key "openbao_clusters", "organizations"
  add_foreign_key "openbao_clusters", "virtual_networks"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "organizations", "agent_pools", column: "agent_id"
  add_foreign_key "plans", "organizations"
  add_foreign_key "policies", "organizations"
  add_foreign_key "policies", "policy_sets"
  add_foreign_key "policy_evaluations", "task_stages"
  add_foreign_key "policy_set_outcomes", "policy_evaluations"
  add_foreign_key "policy_sets", "organizations"
  add_foreign_key "projects", "organizations"
  add_foreign_key "provider_version_platforms", "provider_versions"
  add_foreign_key "provider_versions", "providers"
  add_foreign_key "providers", "organizations"
  add_foreign_key "registry_module_versions", "registry_modules"
  add_foreign_key "registry_modules", "organizations"
  add_foreign_key "run_tasks", "organizations"
  add_foreign_key "run_triggers", "workspaces"
  add_foreign_key "run_triggers", "workspaces", column: "sourceable_id"
  add_foreign_key "runs", "agent_pools", column: "agent_id"
  add_foreign_key "runs", "applies"
  add_foreign_key "runs", "configuration_versions"
  add_foreign_key "runs", "organizations"
  add_foreign_key "runs", "plans"
  add_foreign_key "runs", "workspaces"
  add_foreign_key "ssh_keys", "organizations"
  add_foreign_key "state_version_outputs", "organizations"
  add_foreign_key "state_version_outputs", "state_versions"
  add_foreign_key "state_versions", "organizations"
  add_foreign_key "state_versions", "runs"
  add_foreign_key "state_versions", "workspaces"
  add_foreign_key "taggings", "tags"
  add_foreign_key "task_results", "task_stages"
  add_foreign_key "task_stages", "runs"
  add_foreign_key "team_memberships", "organizations"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "team_projects", "organizations"
  add_foreign_key "team_projects", "projects"
  add_foreign_key "team_projects", "teams"
  add_foreign_key "teams", "organizations"
  add_foreign_key "variable_sets", "organizations"
  add_foreign_key "variables", "organizations"
  add_foreign_key "variables", "variable_sets"
  add_foreign_key "variables", "workspaces"
  add_foreign_key "vcs_connections", "organizations"
  add_foreign_key "virtual_networks", "organizations"
  add_foreign_key "workspace_policy_sets", "policy_sets"
  add_foreign_key "workspace_policy_sets", "workspaces"
  add_foreign_key "workspace_resources", "organizations"
  add_foreign_key "workspace_resources", "state_versions"
  add_foreign_key "workspace_tasks", "run_tasks"
  add_foreign_key "workspace_tasks", "workspaces"
  add_foreign_key "workspace_teams", "organizations"
  add_foreign_key "workspace_teams", "teams"
  add_foreign_key "workspace_teams", "workspaces"
  add_foreign_key "workspaces", "agent_pools"
  add_foreign_key "workspaces", "configuration_versions", column: "current_configuration_version_id"
  add_foreign_key "workspaces", "organizations"
  add_foreign_key "workspaces", "projects"
  add_foreign_key "workspaces", "runs", column: "current_run_id"
  add_foreign_key "workspaces", "state_versions", column: "current_state_version_id"
  add_foreign_key "workspaces", "vcs_connections"
end
