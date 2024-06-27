require 'rubygems/package'

class GenerateConfigurationVersionJob
  include Sidekiq::Job

  # TODO: Fix authentication with github app
  # https://api.github.com/repos/:org/:repo/zipball/:ref will redirect p
  # to a URL for downloading the tarball?
  def perform(run_id)
    # Get our workspace / VCS connection ID
    @run = Run.find(run_id)
    @workspace = @run.workspace

    if @run.configuration_version.nil?
      puts "Configuration version nil, preseeding"
      version = @workspace.configuration_versions.new(
        source: @workspace.source,
        speculative: false,
        status: "fetching",
        provisional: true
      )
      version.organization = @workspace.organization
      version.save!
      puts version.id
      @run.configuration_version = version
      @run.save!
    end

    # If we've already processed this configuration version
    # just go ahead and ignore
    if @run.configuration_version.archive.attached?
      puts "Run already has configuration version attached"
      return
    end

    # If we've previously archived this configuration version,
    # we don't want to recreate it
    if @run.configuration_version.status == "archived"
      puts "Configuration version has already been archived"
      return
    end

    puts "Fetching the configuration version"
    @run.update(status: "fetching")

    path = SecureRandom.hex
    uri = URI(@workspace.source)
    uri.user = "chushi"
    uri.password = @workspace.vcs_connection.github_personal_access_token

    # TODO: Shallow clone only the required directory(ies)
    Git.clone(uri, path)

    archive_name = "#{path}.tar.gz"

    begin
      # Generate a tar.gz file
      File.open(archive_name, "wb") do |file|
        Zlib::GzipWriter.wrap(file) do |gzip|
          Gem::Package::TarWriter.new(gzip) do |tar|
            Dir["#{path}/#{@workspace.working_directory}/**"].reject{|f|f==archive_name}.each do |source_file|
              data = File.read(source_file)
              tar.add_file_simple(source_file.delete_prefix("#{path}/"), 0444, data.length) do |io|
                io.write(data)
              end
            end
          end
        end
      end

      @run.configuration_version.archive.attach(io: File.open(archive_name), filename: "archive")
      @run.configuration_version.update(status: "uploaded")
      @run.update(status: "fetching_completed")

    ensure
      FileUtils.remove_file(archive_name) if File.exist?(archive_name)
      FileUtils.remove_dir(path) if File.exist?(path)
    end

    puts "Configuration version completed"
    @run.update(status: "plan_queued")
  end
end
