Rails.application.routes.draw do
  defaults format: :json do
    resources :users
    resources :lists do
      resources :items
    end
    resources :user_sessions

    root to: 'user_sessions#new'
  end
end
