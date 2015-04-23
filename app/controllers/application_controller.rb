class ApplicationController < ActionController::Base
	rescue_from ActionController::RoutingError, with: :not_found
	rescue_from ActiveRecord::RecordNotFound, with: :not_found

	rescue_from 'ActionController::UnpermittedParameters' do |e|
		render json: { message: e.message }, status: 422
	end 

  private

    def render_errors_for(object)
	  	render json: { message: object.errors }, status: 422
	  end

		def not_found
			render json: { message: "page not found" }, status: 404
		end
end