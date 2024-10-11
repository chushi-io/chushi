class PolicyEvaluation < ApplicationRecord
  belongs_to :task_stage
  has_many :policy_set_outcomes

  before_create -> { generate_id("poleval") }
end
