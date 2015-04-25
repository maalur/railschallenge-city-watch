Rails.application.routes.draw do
  resources :emergencies, except: [:new, :edit, :destroy], defaults: { format: :json }
  resources :responders, except: [:new, :edit, :destroy], defaults: { format: :json }

  match '*path', to: 'application#not_found', via: :all
end
