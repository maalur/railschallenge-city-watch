Rails.application.routes.draw do
	
	match "*path", to: "errors#catch_404", via: :all
end
