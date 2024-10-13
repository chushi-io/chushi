class WorkspaceTask < ApplicationRecord
  belongs_to :workspace
  belongs_to :run_task, dependent: :destroy

  before_create -> { generate_id('wstask') }
end
