class EmergenciesController < ApplicationController

	before_action :find_emergency, only: [:show, :update]

	def show
	end

	def index
    @emergencies = Emergency.all
    @full_responses = [@emergencies.with_full_response.length, @emergencies.length]
  end

	def create
		@emergency = Emergency.new(emergency_params)
		if @emergency.save
			Responder.dispatch_for(@emergency) if @emergency.response_required?
			render 'show', status: 201
		else
			render_errors_for(@emergency)
		end
	end

	def update
    if @emergency.update_attributes(emergency_params)
    	@emergency.responders.each(&:unassign)
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