# frozen_string_literal: true

class ApplicationSerializer
  include JSONAPI::Serializer

  include ActionPolicy::Behaviour

  set_key_transform :dash
  set_id(&:external_id) # <- encoded id!
  #
  #   class << self
  #     attr_reader :rules
  #
  #     def expose_rules(*rules)
  #       # very basic implementation; ideally we need to handle inheritance here
  #       @rules = rules
  #     end
  #   end
  #
  #   def initialize(target)
  #     @target = target
  #   end
  #
  #   def serialize_for(context)
  #     policy = policy_for(target)
  #     self.class.rules.each_with_object({}) do |rule, acc|
  #       # invoke rule (that populates the policy.result object)
  #       policy.apply(rule)
  #       acc[rule] = policy.result.as_json # not sure what this method returns, we should probably add support fro this
  #       acc
  #     end
  #   end
end
