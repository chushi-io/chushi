class AddOrganizationIdToProviders < ActiveRecord::Migration[7.1]
  def change
    add_reference :providers, :organization, index: true, foreign_key: true, type: :uuid
  end
end
