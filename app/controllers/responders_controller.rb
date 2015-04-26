class RespondersController < ApplicationController
  def create
    @responder = Responder.new(permitted_params)
    if @responder.save
      render :show, status: :created
    else
      render_errors_for(@responder)
    end
  end

  def index
    if params[:show] == 'capacity'
      @capacities = Responder.total_capacities_map
      render json: { capacity: @capacities }
    else
      @responders = Responder.all
    end
  end

  def show
    find_responder
  end

  def update
    find_responder
    if @responder.update_attributes(permitted_params)
      render :show, status: :ok
    else
      render_errors_for(@responder)
    end
  end

  private

  def params_for_action
    { 'create' => [:type, :name, :capacity], 'update' => [:on_duty] }[params[:action]]
  end

  def find_responder
    @responder = Responder.find_by!(name: params[:id])
  end

  def permitted_params
    params.require(:responder).permit(params_for_action)
  end
end
