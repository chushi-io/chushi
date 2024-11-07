# frozen_string_literal: true

class CloudProviderSerializer < ApplicationSerializer
  set_type 'cloud-providers'

  attribute :cloud
  attribute :name
  attribute :display_name

  attribute :aws_account_id
  attribute :aws_access_key_id
  attribute :aws_iam_role

  attribute :gcp_project
  attribute :gcp_workload_identity_provider
  attribute :gcp_service_account_email

  attribute :created_at

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
