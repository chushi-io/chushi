# frozen_string_literal: true

class JobSerializer < ApplicationSerializer
  set_id :id
  set_type 'jobs'

  attribute :locked_by
  attribute :status
  attribute :locked
  attribute :operation
  attribute :created_at
  attribute :updated_at

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace

  belongs_to :run, serializer: RunSerializer, id_method_name: :external_id, &:run

  belongs_to :agent_pool, serializer: AgentPoolSerializer, id_method_name: :external_id, &:agent_pool

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization

  # Links for the agent process to upload various files not supported
  # by the SDK directly
  # - log-stream-url # For plan or apply, depending on operation. This is the endpoint
  # we will stream logs to over GRPC for real time logs. Not supported, we'll
  # just leverage full log uploads for now?
  link :log_stream_url, unless: proc { |record, _params|
    %w[errored completed].include?(record.status)
  } do |_object|
    nil
  end

  # - log-upload-url # Upload the full contents of logs after a run is completed
  link :log_upload_url, unless: proc { |record, _params|
    %w[errored completed].include?(record.status)
  } do |object|
    options = if object.operation == 'plan'
                { id: object.run.plan.id, class: object.run.plan.class.name }
              else
                { id: object.run.apply.id, class: object.run.apply.class.name }
              end
    encrypt_upload_url(options)
  end

  # - hosted-json-plan-upload-url # To upload JSON plan format
  link :hosted_json_plan_upload_url, if: proc { |record, _params|
    record.operation == 'plan' && %w[running pending].include?(record.status)
  } do |object|
    options = { id: object.run.plan.id, class: object.run.plan.class.name, filename: 'tfplan.json' }
    encrypt_upload_url(options)
  end

  # - hosted-plan-upload-url # For uploading the binary plan file
  link :hosted_plan_upload_url, if: proc { |record, _params|
    record.operation == 'plan' && %w[running pending].include?(record.status)
  } do |object|
    options = { id: object.run.plan.id, class: object.run.plan.class.name, filename: 'tfplan' }
    encrypt_upload_url(options)
  end

  # - hosted-structured-json-upload-url # For uploading the structured output
  link :hosted_plan_upload_url, if: proc { |record, _params|
    record.operation == 'plan' && %w[running pending].include?(record.status)
  } do |object|
    options = { id: object.run.plan.id, class: object.run.plan.class.name, filename: 'structured.json' }
    encrypt_upload_url(options)
  end
end
