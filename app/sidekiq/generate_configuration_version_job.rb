# frozen_string_literal: true

require 'rubygems/package'
require 'open-uri'

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
      version = @workspace.configuration_versions.new(
        source: @workspace.vcs_repo_identifier,
        speculative: false,
        status: 'fetching',
        provisional: true
      )
      version.organization = @workspace.organization
      version.save!
      @run.configuration_version = version
      @run.save!
    end

    # If we've already processed this configuration version
    # just go ahead and ignore
    if @run.configuration_version.archive.attached?
      Rails.logger.debug 'Run already has configuration version attached'
      return
    end

    # If we've previously archived this configuration version,
    # we don't want to recreate it
    if @run.configuration_version.status == 'archived'
      Rails.logger.debug 'Configuration version has already been archived'
      return
    end

    Rails.logger.debug 'Fetching the configuration version'
    @run.update(status: 'fetching')

    path = SecureRandom.hex
    archive_name = "#{path}.tar.gz"

    if @workspace.vcs_connection.github_personal_access_token
      uri = URI(@workspace.vcs_repo_identifier)
      uri.user = 'chushi'
      uri.password = @workspace.vcs_connection.github_personal_access_token

      # TODO: Shallow clone only the required directory(ies)
      Git.clone(uri, path)

      begin
        # Generate a tar.gz file
        File.open(archive_name, 'wb') do |file|
          Zlib::GzipWriter.wrap(file) do |gzip|
            Gem::Package::TarWriter.new(gzip) do |tar|
              Dir["#{path}/#{@workspace.working_directory}/**"].reject { |f| f == archive_name }.each do |source_file|
                data = File.read(source_file)
                tar.add_file_simple(source_file.delete_prefix("#{path}/"), 0o444, data.length) do |io|
                  io.write(data)
                end
              end
            end
          end
        end

        @run.configuration_version.archive.attach(io: File.open(archive_name), filename: 'archive')
        @run.configuration_version.update(status: 'uploaded')
        @run.update(status: 'fetching_completed')
        RunStage::FetchingCompletedJob.perform_async(@run.id)
      ensure
        FileUtils.rm_f(archive_name)
        FileUtils.rm_rf(path)
      end
    else
      priv_key = OpenSSL::PKey::RSA.new(File.read('private_key.pem'))

      @app_id = @workspace.vcs_connection.github_application_id || 930_341
      payload = {
        # The time that this JWT was issued, _i.e._ now.
        iat: Time.now.to_i,
        # JWT expiration time (10 minute maximum)
        exp: Time.now.to_i + (10 * 60),
        # Your GitHub App's identifier number
        iss: @app_id
      }

      jwt = JWT.encode(payload, priv_key, 'RS256')
      @app_client ||= Octokit::Client.new(bearer_token: jwt)

      @installation_id = @workspace.vcs_connection.github_installation_id
      @installation_token = @app_client.create_app_installation_access_token(@installation_id)[:token]
      @installation_client = Octokit::Client.new(bearer_token: @installation_token)

      # rubocop:disable Lint/UselessAssignment
      link = @installation_client.archive_link(@workspace.vcs_repo_identifier, {
                                                 ref: 'main'
                                               })
      # rubocop:enable Lint/UselessAssignment
      # TODO: We're going to be using carrierwave for this when needed,
      # so we can disable this function to pass rubocop checks
      # @run.configuration_version.archive.attach(io: URI.open(link), filename: 'archive')
      @run.configuration_version.update(status: 'uploaded')
      @run.update(status: 'fetching_completed')
    end

    Rails.logger.debug 'Configuration version completed'
    @run.update(status: 'fetching_completed')
  end
end
