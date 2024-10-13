# frozen_string_literal: true

class TaskResult < ApplicationRecord
  belongs_to :task_stage

  before_create -> { generate_id('taskrs') }
end
