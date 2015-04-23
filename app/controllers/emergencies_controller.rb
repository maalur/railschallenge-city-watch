class EmergenciesController < ApplicationController

	def show
		@emergency = Emergency.find_by!(code: params[:id])
	end

	def create
		@emergency = Emergency.new(emergency_params)
		if @emergency.save
			render 'show', status: 201
		else
			render json: { message: @emergency.errors }, status: 422
		end
	end

	private

	  def emergency_params
	  	params.require(:emergency).permit(permitted_params)
	  end

	  def permitted_params
	  	[:code, :fire_severity, :police_severity, :medical_severity]
	  end

end