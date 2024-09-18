class SshKey < ApplicationRecord
  belongs_to :organization

  before_create -> { generate_id("sshkey") }
end
