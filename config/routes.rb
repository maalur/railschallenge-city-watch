Rails.application.routes.draw do
	resources :emergencies, except: [:new, :edit, :destroy], defaults: { format: :json }

	match "*path", to: "errors#catch_404", via: :all
end
