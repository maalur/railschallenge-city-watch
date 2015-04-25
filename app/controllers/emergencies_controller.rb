class EmergenciesController < ApplicationController
  def show
    find_emergency
  end

  def index
    @emergencies = Emergency.all
    @full_responses = [@emergencies.where(full_response: true).length, @emergencies.length]
  end

  def create
    @emergency = Emergency.new(emergency_params)
    if @emergency.save
      @emergency.dispatch!
      render :show, status: :created
    else
      render_errors_for(@emergency)
    end
  end

  def update
    find_emergency
    if @emergency.update_attributes(emergency_params)
      @emergency.adjust_response!
      render :show, status: :ok
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
      'create' => [:code],
      'update' => [:resolved_at]
    }[params[:action]] + [:fire_severity, :police_severity, :medical_severity]
  end
end
