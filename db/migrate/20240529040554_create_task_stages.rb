class CreateTaskStages < ActiveRecord::Migration[7.1]
  def change
    create_table :task_stages, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :stage
      t.string :status

      t.references :run, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
