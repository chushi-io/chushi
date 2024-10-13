# frozen_string_literal: true

class PolicySetOutcome < ApplicationRecord
  belongs_to :policy_evaluation

  before_create -> { generate_id('') }
end
