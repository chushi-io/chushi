# frozen_string_literal: true

class CreatePolicySets < ActiveRecord::Migration[7.1]
  def change
    create_table :policy_sets, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :name
      t.string :description
      t.boolean :global
      t.string :kind
      t.boolean :overridable

      t.string :vcs_repo_branch
      t.string :vcs_repo_identifier
      t.string :ingress_submodules
      t.string :vcs_repo_oauth_token_id

      t.references :organization, foreign_key: true, type: :uuid
      t.index %i[organization_id name], unique: true

      t.timestamps
    end
  end
end
