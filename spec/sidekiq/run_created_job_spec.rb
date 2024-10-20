# frozen_string_literal: true

require 'rails_helper'

require 'sidekiq/testing'

describe RunCreatedJob do
  Sidekiq::Testing.disable!

  organization = Fabricate(:organization)
  workspace = Fabricate(:workspace, organization:)

  context 'when configuration_version is not uploaded' do
    configuration_version = Fabricate(:configuration_version, workspace:, organization:, status: 'fetching')
    run = Fabricate(:run, workspace:, organization:, configuration_version:, status: 'pending')
    it 'does not update status' do
      worker = described_class.new
      worker.perform(run.id)
      run = Run.find(run.id)
      expect(run.status).to eq('pending')
    end
  end

  context 'when run has "pre_plan" task stages' do
    configuration_version = Fabricate(:configuration_version, workspace:, organization:, status: 'uploaded')
    run = Fabricate(:run, workspace:, organization:, configuration_version:, status: 'pending')
    Fabricate(:task_stage, run:)
    it 'sets status to "pre_plan_running"' do
      worker = described_class.new
      worker.perform(run.id)
      run = Run.find(run.id)
      expect(run.status).to eq('pre_plan_running')
    end
  end

  context 'when run does not have "pre_plan" task stages' do
    configuration_version = Fabricate(:configuration_version, workspace:, organization:, status: 'uploaded')
    run = Fabricate(:run, workspace:, organization:, configuration_version:, status: 'pending')
    it 'sets status to "plan_queued"' do
      worker = described_class.new
      worker.perform(run.id)
      run = Run.find(run.id)
      expect(run.status).to eq('plan_queued')

      job = Job.where(run_id: run.id, operation: 'plan').first
      assert(job).present?
    end
  end
end
