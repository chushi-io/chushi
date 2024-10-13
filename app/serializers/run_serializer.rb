# frozen_string_literal: true

class RunSerializer < ApplicationSerializer
  set_type :runs

  attribute :actions do |_object|
    {
      'is-confirmable': true
    }
  end
  attribute :canceled_at do |_o|
    nil
  end
  attribute :created_at
  attribute :has_changes
  attribute :auto_apply
  attribute :allow_empty_apply do |_o|
    true
  end
  attribute :allow_config_generation do |_o|
    false
  end
  attribute :is_destroy
  attribute :message
  attribute :plan_only
  attribute :source do |_o|
    'tfe-api'
  end
  attribute :status
  attribute :trigger_reason do |_o|
    'manual'
  end
  attribute :target_addrs do |_o|
    []
  end
  attribute :permissions do |_o|
    {}
  end
  attribute :refresh do |_o|
    false
  end
  attribute :refresh_only do |_o|
    false
  end
  attribute :refresh_addrs do |_o|
    false
  end
  attribute :save_plan do |_o|
    true
  end
  attribute :variables do |_o|
    []
  end

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace
  has_one :configuration_version, key: 'configuration-version', serializer: ConfigurationVersionSerializer,
                                  id_method_name: :external_id, &:configuration_version
  has_one :plan, serializer: PlanSerializer, id_method_name: :external_id, &:plan
  has_one :apply, serializer: ApplySerializer, id_method_name: :external_id, &:apply
  has_many :task_stages, serializer: TaskStageSerializer, id_method_name: :external_id, &:task_stages
end
