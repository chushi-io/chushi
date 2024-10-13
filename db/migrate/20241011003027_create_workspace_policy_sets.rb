class CreateWorkspacePolicySets < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_policy_sets, id: :uuid do |t|
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :policy_set, foreign_key: true, type: :uuid
      t.index %i[workspace_id policy_set_id], unique: true

      t.timestamps
    end
  end
end
