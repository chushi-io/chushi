class RunSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

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
  attribute :is_destroy do |o| false end
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

  belongs_to :workspace
  has_one :configuration_version, key: "configuration-version"
  has_one :plan
  has_one :apply
  has_many :task_stages
end
