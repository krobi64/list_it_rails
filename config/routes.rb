Rails.application.routes.draw do
  defaults format: :json do
    resources :lists do
      member do
        put '/share', to: 'lists#share'
      end
      resources :items
    end

    resources :accounts

    post 'authenticate', to: 'authentication#authenticate'

    match '*unmatched', to: 'application#route_not_found', via: :all
  end
end
