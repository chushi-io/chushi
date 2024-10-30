# frozen_string_literal: true

module Api
  module V2
    class TaskStagesController < Api::ApiController
      def index
        @run = Run.find_by(external_id: params[:id])
        authorize! @run.workspace, to: :can_read_run?

        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        render json: ::TaskStageSerializer.new(@run.task_stages, options).serializable_hash
      end

      def show
        @task_stage = TaskStage.find_by(external_id: params[:task_stage_id])
        authorize! @task_stage.run.workspace, to: :read?

        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        render json: ::TaskStageSerializer.new(@task_stage, options).serializable_hash
      end
    end
  end
end
