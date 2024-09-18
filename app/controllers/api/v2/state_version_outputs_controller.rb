class Api::V2::StateVersionOutputsController < Api::ApiController
  def show
    @output = StateVersionOutput.find_by(external_id: params[:id])
    unless @output
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @output.state_version.workspace, to: :show?
    render json: ::StateVersionOutputSerializer.new(@output, {}).serializable_hash
  end
end
