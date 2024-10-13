class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  protected

  def generate_id(prefix)
    self.external_id = "#{prefix}-#{SecureRandom.alphanumeric(16)}"
  end
end
