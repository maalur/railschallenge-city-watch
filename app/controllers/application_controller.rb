class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  rescue_from 'ActionController::UnpermittedParameters' do |e|
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def not_found
    render json: { message: 'page not found' }, status: :not_found
  end

  private

  def render_errors_for(object)
    render json: { message: object.errors }, status: :unprocessable_entity
  end
end
