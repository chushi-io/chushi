class OrganizationSerializer < ApplicationSerializer
  set_type :organizations
  set_id :name

  attribute :external_id
  attribute :created_at
  attribute :email
  attribute :collaborator_auth_policy do |_o| 'password' end
  attribute :default_execution_mode
end
