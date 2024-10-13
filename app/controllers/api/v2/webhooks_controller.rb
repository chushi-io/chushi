class Api::V2::WebhooksController < Api::ApiController
  skip_before_action :verify_access_token
  skip_verify_authorized only: :create

  before_action :verify_hmac

  # install_url: https://github.com/apps/chushi-development/installations/new?state=foo
  # HTTP_X_GITHUB_DELIVERY='2c88a7b0-33e7-11ef-9e55-5aa827750965'
  # HTTP_X_GITHUB_EVENT='check_suite'
  # HTTP_X_GITHUB_HOOK_ID='486481548'
  # HTTP_X_GITHUB_HOOK_INSTALLATION_TARGET_ID='930341'
  # HTTP_X_GITHUB_HOOK_INSTALLATION_TARGET_TYPE='integration'
  # HTTP_X_HUB_SIGNATURE='sha1=02ada2d50f51f88f0552f0c3e4b8ed162e09f788'
  # HTTP_X_HUB_SIGNATURE_256='sha256=88a22f8ed32517874df1e83cfbfa71b473fe35089bc48fc64f68cf95ef448e3d'
  # HTTP_ACCEPT_ENCODING='gzip'
  # HTTP_VERSION='HTTP/1.1'
  def create
    @webhook_id = "webhook:#{request.headers['X-GitHub-Delivery']}"
    payload = JSON.parse(request.raw_post)
    Rails.cache.write(@webhook_id, payload)

    case request.headers['X-GitHub-Event']
    when 'installation'
      # Don't do anything for now
    when 'push'
      Webhook::PushEventJob.perform_async(@webhook_id)
    when 'pull_request'
      Webhook::PullRequestJob.perform_async(@webhook_id)
    else
      logger.info "unknown webhook event: #{request.headers['X-GitHub-Event']}"
    end

    head :no_content
  end

  private

  def verify_hmac; end
end
