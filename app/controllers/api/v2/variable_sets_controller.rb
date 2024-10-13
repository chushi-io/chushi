# frozen_string_literal: true

module Api
  module V2
    class VariableSetsController < Api::ApiController
      before_action :load_varset, except: %i[index create]
      def index
        @org = Organization.find_by(external_id: params[:organization_id])
        authorize! @org, to: :can_read_varsets?

        @varsets = @org.variable_sets
        render ::VariableSetSerializer.new(@varsets, {}).serializable_hash
      end

      def show
        unless @varset
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @varset.organization, to: :can_manage_varsets?
        render json: ::VariableSetSerializer.new(@varset, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_manage_varsets?

        @varset = @org.variable_sets.new(varset_params)
        if @varset.save
          render json: ::VariableSetSerializer.new(@varset, {}).serializable_hash
        else
          render json: @varset.errors.full_messages, status: :bad_request
        end
      end

      def update
        authorize! @varset.organization, to: :can_manage_varsets?
        if @varset.update(varset_params)
          render json: ::VariableSetSerializer.new(@varset, {}).serializable_hash
        else
          render json: @varset.errors.full_messages, status: :bad_request
        end
      end

      def destroy
        authorize! @varset.organization, to: :can_manage_varsets?
        if @varset.delete
          render status: :no_content
        else
          render status: :internal_server_error
        end
      end

      def list_variables; end

      def add_variable; end

      def update_variable; end

      def delete_variable; end

      def add_workspaces; end

      def delete_workspaces; end

      def add_projects; end

      def delete_projects; end

      private

      def varset_params
        map_params(%i[
                     name
                     description
                     global
                     priority
                   ])
      end

      def load_varset
        @varset = VariableSet.find_by(external_id: params[:id])
      end
    end
  end
end
