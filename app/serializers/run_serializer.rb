class RunSerializer < ApplicationSerializer
  set_type :runs

  attribute :actions do |object| {
    "is-confirmable": true
  } end
  attribute :canceled_at do |o| nil end
  attribute :created_at
  attribute :has_changes
  attribute :auto_apply
  attribute :allow_empty_apply do |o| true end
  attribute :allow_config_generation do |o| false end
  attribute :is_destroy
  attribute :message
  attribute :plan_only
  attribute :source do |o| "tfe-api" end
  attribute :status
  attribute :trigger_reason do |o| "manual" end
  attribute :target_addrs do |o| [] end
  attribute :permissions do |o| {} end
  attribute :refresh do |o| false end
  attribute :refresh_only do |o| false end
  attribute :refresh_addrs do |o| false end
  attribute :save_plan do |o| true end
  attribute :variables do |o| [] end

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.workspace
  end
  has_one :configuration_version, key: "configuration-version", serializer: ConfigurationVersionSerializer, id_method_name: :external_id do |object|
    object.configuration_version
  end
  has_one :plan, serializer: PlanSerializer, id_method_name: :external_id do |object|
    object.plan
  end
  has_one :apply, serializer: ApplySerializer, id_method_name: :external_id do |object|
    object.apply
  end
  has_many :task_stages, serializer: TaskStageSerializer, id_method_name: :external_id do |object|
    object.task_stages
  end
end
