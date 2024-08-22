class RunTask < ApplicationRecord
  belongs_to :organization

  before_create -> { generate_id("task") }
end
