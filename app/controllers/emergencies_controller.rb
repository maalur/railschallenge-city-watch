class EmergenciesController < ApplicationController
  def create
    @emergency = Emergency.new(permitted_params)
    if @emergency.save
      @emergency.dispatch!
      render :show, status: :created
    else
      render_errors_for(@emergency)
    end
  end

  def index
    @emergencies = Emergency.includes(:responders).all
    @full_responses = [@emergencies.where(full_response: true).length, @emergencies.length]
  end

  def show
    find_emergency
  end

  def update
    find_emergency
    if @emergency.update_attributes(permitted_params)
      @emergency.adjust_response!
      render :show, status: :ok
    else
      render_errors_for(@emergency)
    end
  end

  private

  def permitted_params
    params.require(:emergency).permit(params_for_action)
  end

  def find_emergency
    @emergency = Emergency.find_by!(code: params[:id])
  end

  def params_for_action
    { 'create' => [:code], 'update' => [:resolved_at] }[params[:action]]
    .+ [:fire_severity, :police_severity, :medical_severity]
  end
end
