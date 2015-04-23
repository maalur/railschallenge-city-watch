class RespondersController < ApplicationController

	before_action :find_responder, only: [:show, :update]

	def show
	end

	def index
		if params[:show] == 'capacity'
			@capacities = Responder.responder_capacities
			render json: { capacity: @capacities }
		else
		  @responders = Responder.all
	  end
	end

	def update
		if @responder.update_attributes(permitted_params)
		  render 'show'
		else
			render_errors_for(@responder)
		end
	end

	def create
    @responder = Responder.new(permitted_params)
    if @responder.save
    	render 'show', status: 201
    else
    	render_errors_for(@responder)
    end
	end

	private

	  def find_responder
	  	@responder = Responder.find_by!(name: params[:id])
	  end

	  def permitted_params
	  	params.require(:responder).permit(action_params[params[:action]])
	  end

	  def action_params
	  	{ 'create' => [:type, :name, :capacity], 'update' => [:on_duty] }
	  end
end