# frozen_string_literal: true

module Api
  module V2
    class TaskResultsController < Api::ApiController
      # include ::HTTParty
      skip_verify_authorized
      skip_before_action :verify_access_token
      def callback
        # TODO: This endpoint not currently authenticated
        @task_result = TaskResult.find_by(external_id: params[:task_result_id])
        if @task_result.update(task_result_params)
          TaskResult::TaskResultCompletedJob.perform_async(@task_result.id)
          render json: ::TaskResultSerializer.new(@task_result, {}).serializable_hash
        else
          render json: @task_result.errors.full_messages, status: :bad_request
        end
      end

      def null_stage
        @response = ::HTTParty.patch(params[:task_result_callback_url], body: {
                                       data: {
                                         type: 'task-results',
                                         attributes: {
                                           status: 'passed',
                                           message: '4 passed, 0 skipped, 0 failed',
                                           url: 'https://some-non-existent-url.com'
                                         }
                                       }
                                     }, headers: {
                                       Authorization: "Bearer #{params[:access_token]}"
                                     })
        Rails.logger.debug @response.to_json
        head :ok
      end

      private

      def task_result_params
        map_params(%i[
                     status
                     message
                     url
                   ])
      end
    end
  end
end

class NullResultSerializer
  include JSONAPI::Serializer

  set_key_transform :dash
  set_type 'task-results'
  set_id(&:id)

  attribute :status
  attribute :message
  attribute :url

  # TODO: Also post outcomes
end
