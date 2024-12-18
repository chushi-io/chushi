# frozen_string_literal: true

module Api
  module V2
    class ProjectsController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?

        @projects = @org.projects
        render json: ::ProjectSerializer.new(@projects, {}).serializable_hash
      end

      def show
        @project = Project.find_by(external_id: params[:id])
        unless @project
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @project.organization, to: :read?
        render json: ::ProjectSerializer.new(@project, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_create_project?

        @project = @org.projects.new(project_params)
        if @project.save
          render json: ::ProjectSerializer.new(@project, {}).serializable_hash
        else
          render json: @project.errors.full_messages, status: :bad_request
        end
      end

      def update
        @project = Project.find_by(external_id: params[:id])
        authorize! @project, to: :can_update?
        if @project.update(project_params)
          render json: ::ProjectSerializer.new(@project, {}).serializable_hash
        else
          render json: @project.errors.full_messages, status: :bad_request
        end
      end

      def destroy
        @project = Project.find_by(external_id: params[:id])
        authorize! @project, to: :can_update?
        if @project.delete
          render status: :no_content
        else
          render status: :internal_server_error
        end
      end

      private

      def project_params
        map_params(%i[name description])
      end
    end
  end
end
