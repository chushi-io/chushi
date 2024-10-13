class StateVersionOutputSerializer < ApplicationSerializer
  set_type 'state-version-outputs'

  attribute :name
  attribute :sensitive
  attribute :type, if: proc { |record|
    record.output_type.present?
  } do |o|
    JSON.parse(o.output_type)[0]
  rescue StandardError
    o.output_type
  end
  attribute :value, if: proc { |record|
    record.value.present?
  } do |o|
    JSON.parse(o.value)
  rescue StandardError
    o.value
  end
  attribute :detailed_type do |object|
    JSON.parse(object.output_type)
  rescue StandardError
    object.output_type
  end
end
