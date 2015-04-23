class EmergenciesController < ApplicationController

	before_action :find_emergency, only: [:show, :update]

	def show
	end

	def index
    @emergencies = Emergency.all
  end

	def create
		@emergency = Emergency.new(emergency_params)
		if @emergency.save
			render 'show', status: 201
		else
			render_errors_for(@emergency)
		end
	end

	def update
    if @emergency.update_attributes(emergency_params)
    	render 'show'
    else
    	render_errors_for(@emergency)
    end
	end

	private

	  def find_emergency
	  	@emergency = Emergency.find_by!(code: params[:id])
	  end

	  def emergency_params
	  	params.require(:emergency).permit(permitted_params)
	  end

	  def permitted_params
	  	{
	  		"create" => [:code],
	  		"update" => [:resolved_at]
	  	}[params[:action]] + [:fire_severity, :police_severity, :medical_severity]
	  end

end