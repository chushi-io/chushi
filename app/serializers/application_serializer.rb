class ApplicationSerializer
  include JSONAPI::Serializer

  include ActionPolicy::Behaviour
  singleton_class.include Rails.application.routes.url_helpers

  set_key_transform :dash
  set_id { |object| object.external_id }   # <- encoded id!
=begin

  class << self
    attr_reader :rules

    def expose_rules(*rules)
      # very basic implementation; ideally we need to handle inheritance here
      @rules = rules
    end
  end

  def initialize(target)
    @target = target
  end

  def serialize_for(context)
    policy = policy_for(target)
    self.class.rules.each_with_object({}) do |rule, acc|
      # invoke rule (that populates the policy.result object)
      policy.apply(rule)
      acc[rule] = policy.result.as_json # not sure what this method returns, we should probably add support fro this
      acc
    end
  end
=end

  def self.encrypt_storage_url(object)
    object[:method] = "get"
    token = Vault::Rails.encrypt("transit", "chushi_storage_url", object.to_json)
    enc = Base64.strict_encode64(token)
    api_v2_get_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end

  def self.encrypt_upload_url(object)
    object[:method] = "upload"
    token = Vault::Rails.encrypt("transit", "chushi_storage_url", object.to_json)
    enc = Base64.strict_encode64(token)
    api_v2_upload_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end
end
