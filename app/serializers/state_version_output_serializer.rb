class StateVersionOutputSerializer < ApplicationSerializer
  set_type "state-version-outputs"

  attribute :name
  attribute :sensitive
  attribute :type, if: Proc.new { |record|
    record.output_type.present?
  } do |o|
    begin
      JSON.parse(o.output_type)[0]
    rescue
      o.output_type
    end
  end
  attribute :value, if: Proc.new{ |record|
    record.value.present?
  } do |o|
    begin
      JSON.parse(o.value)
    rescue
      o.value
    end
  end
  attribute :detailed_type do |object|
    begin
      JSON.parse(object.output_type)
    rescue
      object.output_type
    end
  end
end
