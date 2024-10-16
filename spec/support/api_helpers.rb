# frozen_string_literal: true

module ApiHelpers
  def common_headers
    {
      'Content-Type': 'application/json'
    }
  end

  def seed_org
    organization = Fabricate(:organization)
    token = Fabricate(:access_token, token_authable: organization)
    organization.teams.create(name: 'owners')
    [organization, token]
  end

  def seed_user_with_teams(organization_id, teams = [])
    user = Fabricate(:user)
    user_token = Fabricate(:access_token, token_authable: user)
    OrganizationMembership.create(user_id: user.id, organization_id:)
    teams.each do |team|
      team.users << user
      team.save!
    end
    [user, user_token]
  end

  def workspace_params(project_id = nil)
    relationships = {}
    unless project_id.nil?
      relationships['project'] = {
        'data' => {
          'type' => 'projects',
          'id' => project_id
        }
      }
    end
    workspace = {
      'data' => {
        'type' => 'workspaces',
        'attributes' => {
          'name' => Faker::Alphanumeric.alpha(number: 10)
        },
        'relationships' => relationships
      }
    }
    workspace
  end

  def workspace_update_params
    {
      'data' => {
        'type' => 'workspaces',
        'attributes' => {
          'name' => Faker::Alphanumeric.alpha(number: 10),
          'execution-mode' => 'local'
        }
      }
    }
  end

  def base_run_params(workspace, config_version, attrs = {})
    {
      "data": {
        "attributes": {
          "message": Faker::Alphanumeric.alpha(number: 20)
        }.merge(attrs),
        "type":"runs",
        "relationships": {
          "workspace": {
            "data": {
              "type": "workspaces",
              "id": workspace.external_id,
            }
          },
          "configuration-version": {
            "data": {
              "type": "configuration-versions",
              "id": config_version.external_id
            }
          }
        }
      }
    }

    # def parse_response(response)
    #   jsonapi_deserialize(JSON.parse(response))
    # end
  end
end
