class CleanupArchivedConfigurationsJob
  include Sidekiq::Job

  def perform(*args)
    ConfigurationVersion.where(status: "archived").each do |version|
      version.archive.purge
    end
  end
end
