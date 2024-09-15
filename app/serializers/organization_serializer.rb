class OrganizationSerializer < ApplicationSerializer

  set_type :organizations
  set_id :name

  attribute :external_id
  attribute :created_at
  attribute :email do |o| "" end

end
