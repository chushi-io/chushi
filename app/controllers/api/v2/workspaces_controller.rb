# frozen_string_literal: true

module Api
  module V2
    class WorkspacesController < Api::ApiController
      before_action :load_workspace, except: %i[index create]

      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?

        @workspaces = @org.workspaces
        @workspaces = @workspaces.tagged_with(params[:search][:tags].split(','), match_all: true) if params[:search] && params[:search][:tags][:tags]
        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        render json: ::WorkspaceSerializer.new(@workspaces, options).serializable_hash
      end

      def lock
        authorize! @workspace, to: :can_lock?
        head :conflict and return if @workspace.locked

        @workspace.update(locked: true)
        render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
      end

      def show
        authorize! @workspace, to: :can_access?
        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        render json: ::WorkspaceSerializer.new(@workspace, options).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])

        if workspace_params['project_id']
          @project = Project.where(organization_id: @org.id).find_by(external_id: workspace_params['project_id'])
          authorize! @project, to: :can_create_workspace?
        else
          @project = Project.where(organization_id: @org.id).where(is_default: true).first
          authorize! @org, to: :can_create_workspace?
        end

        @workspace = @org.workspaces.new(workspace_params)
        if @workspace.save
          render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash, status: :created
        else
          render json: @workspace.errors.full_messages, status: :bad_request
        end
      end

      def update
        authorize! @workspace, to: :can_update?
        update_params = workspace_params.to_h
        if update_params.key?('agent_pool_id')
          @agent = @workspace.organization.agent_pools.find_by(external_id: update_params['agent_pool_id'])
          update_params['agent_pool_id'] = @agent.id
        end
        if update_params.key?('terraform_version')
          update_params['tofu_version'] = update_params['terraform_version']
          update_params.delete('terraform_version')
        end
        if @workspace.update(update_params)
          render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
        else
          render json: @workspace.errors.full_messages, status: :bad_request
        end
      end

      def unlock
        authorize! @workspace, to: :can_unlock?
        @workspace.update(locked: false) if @workspace.locked
        render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
      end

      def force_unlock
        authorize! @workspace, to: :can_force_unlock?
        head :conflict and return unless @workspace.locked

        @workspace.update(locked: false)
        render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
      end

      def runs
        authorize! @workspace, to: :can_read_run?
        @runs = @workspace.runs
        render json: ::RunSerializer.new(@runs, {}).serializable_hash
      end

      def tags
        authorize! @workspace, to: :read?
        params.permit!

        nil unless request.get?
        # Simply get the workspace tags
      end

      def destroy
        authorize! @workspace, to: :can_force_delete?
        head :no_content
      end

      private

      def tag_params
        params.permit(
          [
            :type,
            { attributes: [:name] }
          ],
          :id
        )
      end

      def load_workspace
        @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
        raise ActiveRecord::RecordNotFound unless @workspace
      end

      def workspace_params
        map_params([
                     :name,
                     'agent-pool-id',
                     'allow-destroy-plan',
                     'auto-apply',
                     'auto-apply-run-trigger',
                     'auto-destroy-at',
                     'auto-destroy-at-activity-duration',
                     'description',
                     'execution-mode',
                     'file-triggers-enabled',
                     'global-remote-state',
                     'queue-all-runs',
                     'source-name',
                     'source-url',
                     'speculative-enabled',
                     'terraform-version',
                     'trigger-patterns',
                     'trigger-prefixes',
                     'working-directory',
                     :project
                   ])
      end
    end
  end
end
