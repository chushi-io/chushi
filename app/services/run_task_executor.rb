class RunTaskExecutor < ApplicationService
  include Rails.application.routes.url_helpers
  attr_reader :task_result

  def initialize(task_result)
    @task_result = task_result
  end

  def call
    payload = {
      "payload_version": 1,
      "stage": task_result.stage,
      "access_token": "test-token",
      "capabilities": {},
      "configuration_version_download_url": configuration_version_download_api_v2_run_url(
        @task_result.task_stage.run.configuration_version.id
      ),
      "configuration_version_id": @task_result.task_stage.run.configuration_version.id,
      "is_speculative": false,
      "organization_name": @task_result.task_stage.run.workspace.organization.name,
      "plan_json_api_url": "",
      "run_app_url": "",
      "run_created_at": @task_result.task_stage.run.created_at,
      "run_created_by": "",
      "run_id": @task_result.task_stage.run.id,
      "run_message": @task_result.task_stage.run.message,
      "task_result_callback_url": api_v2_task_result_callback_url(@task_result.external_id),
      "task_result_enforcement_level": @task_result.workspace_task_enforcement_level,
      "task_result_id": @task_result.external_id,
      "workspace_app_url": "",
      "workspace_id": @task_result.task_stage.run.workspace.external_id,
      "workspace_name": @task_result.task_stage.run.workspace.name,
      "workspace_working_directory": @task_result.task_stage.run.workspace.working_directory
    }

    uri = URI(@task_result.task_url)
    headers = {
      'Content-Type': 'application/json',
      # TODO: Attach appropriate user agent
      'User-Agent': '',
      # TODO: Provider hash signature for verifying payloads
      'X-Chushi-Task-Signature': '',
    }
    response = Net::HTTP.post(uri, payload.to_json, headers)

    unless response.code === "200"
      raise StandardError.new "Run task request failed"
    end
  end

  class << self
    def default_url_options
      Rails.application.config.action_mailer.default_url_options
    end
  end
end