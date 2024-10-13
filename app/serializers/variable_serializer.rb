class VariableSerializer < ApplicationSerializer
  set_type :vars

  attribute :key do |o|
    o.name
  end
  attribute :value
  attribute :description
  attribute :hcl do |o|
    o.variable_type == 'hcl'
  end
  attribute :sensitive
  attribute :version_id do |_o|
    '00000000000000000000000000'
  end
end
