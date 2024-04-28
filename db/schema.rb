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

ActiveRecord::Schema[7.1].define(version: 2024_04_28_190948) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "status"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.string "api_secret"
    t.index ["api_key"], name: "index_agents_on_api_key", unique: true
    t.index ["organization_id", "name"], name: "index_agents_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_agents_on_organization_id"
  end

  create_table "applies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["organization_id"], name: "index_applies_on_organization_id"
  end

  create_table "configuration_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id"
    t.uuid "organization_id"
    t.string "source"
    t.boolean "speculative"
    t.string "status"
    t.string "upload_url"
    t.boolean "provisional"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_configuration_versions_on_organization_id"
    t.index ["workspace_id"], name: "index_configuration_versions_on_workspace_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.uuid "organization_id"
    t.bigint "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.boolean "allow_auto_create_workspace"
    t.string "organization_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "agent_id"
    t.index ["agent_id"], name: "index_organizations_on_agent_id"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "execution_mode"
    t.boolean "has_changes"
    t.boolean "resource_additions"
    t.boolean "resource_changes"
    t.boolean "resource_destructions"
    t.boolean "resource_imports"
    t.string "status"
    t.string "logs_url"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_plans_on_organization_id"
  end

  create_table "runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["organization_id"], name: "index_runs_on_organization_id"
    t.index ["plan_id"], name: "index_runs_on_plan_id"
    t.index ["workspace_id"], name: "index_runs_on_workspace_id"
  end

  create_table "state_version_outputs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.boolean "sensitive"
    t.string "type"
    t.text "value"
    t.uuid "state_version_id"
    t.uuid "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_state_version_outputs_on_organization_id"
    t.index ["state_version_id"], name: "index_state_version_outputs_on_state_version_id"
  end

  create_table "state_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["organization_id"], name: "index_state_versions_on_organization_id"
    t.index ["run_id"], name: "index_state_versions_on_run_id"
    t.index ["workspace_id"], name: "index_state_versions_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "variable_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "name"
    t.string "description"
    t.boolean "auto_attach"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_variable_sets_on_organization_id"
  end

  create_table "variables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "value"
    t.string "description"
    t.boolean "sensitive"
    t.uuid "organization_id"
    t.uuid "workspace_id"
    t.uuid "variable_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_variables_on_organization_id"
    t.index ["variable_set_id"], name: "index_variables_on_variable_set_id"
    t.index ["workspace_id"], name: "index_variables_on_workspace_id"
  end

  create_table "vcs_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.string "vcs_repo"
    t.string "vcs_repo_identifier"
    t.string "working_directory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "vcs_connection_id"
    t.uuid "organization_id"
    t.uuid "agent_id"
    t.index ["agent_id"], name: "index_workspaces_on_agent_id"
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
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organizations", "agents"
  add_foreign_key "plans", "organizations"
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
  add_foreign_key "variable_sets", "organizations"
  add_foreign_key "variables", "organizations"
  add_foreign_key "variables", "variable_sets"
  add_foreign_key "variables", "workspaces"
  add_foreign_key "vcs_connections", "organizations"
  add_foreign_key "workspace_resources", "organizations"
  add_foreign_key "workspace_resources", "state_versions"
  add_foreign_key "workspaces", "agents"
  add_foreign_key "workspaces", "organizations"
  add_foreign_key "workspaces", "vcs_connections"
end
