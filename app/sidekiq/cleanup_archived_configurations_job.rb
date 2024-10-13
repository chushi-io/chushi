# frozen_string_literal: true

class CleanupArchivedConfigurationsJob
  include Sidekiq::Job

  def perform(*_args)
    ConfigurationVersion.where(status: 'archived').find_each do |version|
      version.archive.purge
    end
  end
end
