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
      @capacities = Responder.responder_capacities
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

  def action_params
    { 'create' => [:type, :name, :capacity], 'update' => [:on_duty] }
  end

  def find_responder
    @responder = Responder.find_by!(name: params[:id])
  end

  def permitted_params
    params.require(:responder).permit(action_params[params[:action]])
  end
end
