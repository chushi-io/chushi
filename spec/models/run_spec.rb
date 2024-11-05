# frozen_string_literal: true

require 'rails_helper'

describe Run do
  it "is not confirmable when status is not 'planned_and_saved'" do
    run = described_class.new(status: 'plan_queued')
    expect(run).not_to be_is_confirmable
  end

  it "is confirmable when status is 'planned_and_saved'" do
    run = described_class.new(status: 'planned_and_saved')
    run.workspace = Workspace.new
    expect(run).to be_is_confirmable
  end
end
