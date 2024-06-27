class TestConnectionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    @workspace = Workspace.find(args.first)
    priv_key = OpenSSL::PKey::RSA.new(File.read("private_key.pem"))

    @app_id = @workspace.vcs_connection.github_application_id || 930341
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

    # Add '//' to the URL to force full parse
    @repo_source = URI.parse("//#{@workspace.source}").path
    @repo = @installation_client.repository(@repo_source.delete_prefix("/"))

    puts @repo
  end
end
