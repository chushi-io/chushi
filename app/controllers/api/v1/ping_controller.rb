class Api::V1::PingController < Api::ApiController
  # skip_before_action :verify_access_token

  def ping
    @agent = current_agent
    @agent.last_ping_at = Time.now
    @agent.ip_address = request.remote_ip
    @agent.save
  end
end
