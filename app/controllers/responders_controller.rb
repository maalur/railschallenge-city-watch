class RespondersController < ApplicationController

	before_action :find_responder, only: [:show, :update]

	def show
	end

	def create
    @responder = Responder.new(responder_params)
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

	  def responder_params
	  	params.require(:responder).permit(permitted_params)
	  end

	  def permitted_params
	  	[:type, :name, :capacity]
	  end
end