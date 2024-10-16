RSpec.shared_examples("can create workspace") do |organization, token|
  it 'can create a workspace' do
    post api_v2_organization_workspaces_path(organization.name), params: {
      'data' => {
        'type' => 'workspaces',
        'attributes' => {
          'name' => Faker::Alphanumeric.alpha(number: 10)
        }
      }
    }.to_json, headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :created
    expect(response).to match_json_schema('workspace', strict: true)
  end
end

RSpec.shared_examples("can update workspace") do |workspace, token|
  it 'can update a workspace' do
    patch api_v2_workspace_path(workspace.external_id), params: {
      'data' => {
        'type' => 'workspaces',
        'attributes' => {
          'name' => Faker::Alphanumeric.alpha(number: 10),
          'execution-mode' => 'local',
        }
      }
    }.to_json, headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :ok
    expect(response).to match_json_schema('workspace', strict: true)
  end
end

RSpec.shared_examples("can delete workspace") do |workspace, token|
  it 'can delete a workspace' do
    delete api_v2_workspace_path(workspace.external_id), headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :no_content
  end
end

RSpec.shared_examples("can lock workspace") do |workspace, token|
  it 'can lock a workspace' do
    workspace.update(locked: false)
    post actions_lock_api_v2_workspace_path(workspace.external_id), headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :ok
    expect(response).to match_json_schema('workspace', strict: true)
  end
end

RSpec.shared_examples("can unlock workspace") do |workspace, token|
  it 'can unlock a workspace' do
    workspace.update(locked: true)
    post actions_unlock_api_v2_workspace_path(workspace.external_id), headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :ok
    expect(response).to match_json_schema('workspace', strict: true)
  end
end

RSpec.shared_examples("can force-unlock workspace") do |workspace, token|
  it 'can force-unlock a workspace' do
    workspace.update!(locked: true)
    post actions_force_unlock_api_v2_workspace_path(workspace.external_id), headers: auth_headers(token).merge(common_headers)
    expect(response).to have_http_status :ok
    expect(response).to match_json_schema('workspace', strict: true)
  end
end
