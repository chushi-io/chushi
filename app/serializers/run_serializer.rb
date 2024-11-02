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
  attribute :has_changes do |o|
    o.has_changes || false
  end
  attribute :auto_apply do |o|
    o.auto_apply || false
  end
  attribute :allow_empty_apply do |_o|
    true
  end
  attribute :allow_config_generation do |_o|
    false
  end
  attribute :is_destroy do |o|
    o.is_destroy || false
  end
  attribute :message
  attribute :plan_only do |o|
    o.plan_only || false
  end
  attribute :source do |_o|
    'tfe-api'
  end
  attribute :status
  attribute :trigger_reason do |_o|
    'manual'
  end
  attribute :target_addrs do |o|
    o.target_addrs || nil
  end
  attribute :permissions do |_o|
    {}
  end
  attribute :refresh do |_o|
    false
  end
  attribute :refresh_only do |o|
    o.refresh_only || false
  end
  attribute :refresh_addrs do |_o|
    # o.refresh_addrs || []
    []
  end
  attribute :save_plan do |_o|
    true
  end
  attribute :variables do |_o|
    []
  end

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace
  has_one :configuration_version, if: proc { |record|
    record.configuration_version.present?
  }, key: 'configuration-version', serializer: ConfigurationVersionSerializer,
                                  id_method_name: :external_id, &:configuration_version

  has_one :plan, if: proc { |record|
    record.plan.present?
  }, serializer: PlanSerializer, id_method_name: :external_id, &:plan
  has_one :apply, if: proc { |record|
    record.apply.present?
  }, serializer: ApplySerializer, id_method_name: :external_id, &:apply
  has_many :task_stages, serializer: TaskStageSerializer, id_method_name: :external_id, &:task_stages
end
