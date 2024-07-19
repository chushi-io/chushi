class VariableSerializer
  include JSONAPI::Serializer
  set_type :vars
  set_key_transform :dash

  attribute :key do |o|
    o.name
  end
  attribute :value
  attribute :description
  attribute :hcl do |o|
    o.variable_type == "hcl"
  end
  attribute :sensitive
  attribute :version_id do |o|
    "00000000000000000000000000"
  end
end
