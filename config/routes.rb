Rails.application.routes.draw do
  defaults format: :json do
    resources :lists do
      resources :items do
        collection do
          put '/reorder', to: 'items#reorder'
        end
      end
    end

    resources :invites, only: [:index, :show, :create, :destroy] do
      member do
        put '/resend', to: 'invites#resend'
      end
    end

    put '/invites/accept', to: 'invites#accept', param: :token, as: :accept
    resources :accounts, only: [:new, :create, :show, :destroy]

    post 'authenticate', to: 'authentication#authenticate'

    match '*unmatched', to: 'application#route_not_found', via: :all
  end
end
