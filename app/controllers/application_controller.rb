class ApplicationController < ActionController::Base
	rescue_from ActionController::RoutingError, with: :not_found

  private

		def not_found
			render :json => { message: "page not found" }, :status => 404
		end
end