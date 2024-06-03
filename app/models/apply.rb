class Apply < ApplicationRecord
  has_one :run

  has_many :state_versions

end
