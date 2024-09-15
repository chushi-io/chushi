after "development:users" do
  @organization = Organization.find_by(name: "chushi")

  @organization.workspaces
    .create_with(
      allow_destroy_plan: true,
      auto_apply: true,
      description: "Default testing workspace",
      execution_mode: "local",
      speculative_enabled: true,
      structured_run_output_enabled: true,
      tofu_version: "1.9.5"
    )
    .find_or_create_by!(name: "chushi-environments-default")

  @organization.workspaces
    .create_with(
      allow_destroy_plan: true,
      auto_apply: true,
      description: "Testing Tags",
      execution_mode: "local",
      speculative_enabled: true,
      structured_run_output_enabled: true,
      tofu_version: "1.9.5"
    )
    .find_or_create_by!(name: "chushi-tags-ws-1")
  @organization.workspaces
    .create_with(
      allow_destroy_plan: true,
      auto_apply: true,
      description: "Default testing workspace",
      execution_mode: "local",
      speculative_enabled: true,
      structured_run_output_enabled: true,
      tofu_version: "1.9.5"
    )
    .find_or_create_by!(name: "chushi-tags-ws-2")

  Workspace.where(name: [
    "chushi-tags-ws-1",
    "chushi-tags-ws-2",
  ]).each do |workspace|
    workspace.tag_list.add("tags:test", "env:dev")
    workspace.save!
  end
end