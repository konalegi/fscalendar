Rails.application.routes.draw do
  resources :events
  resource :user
  devise_for :users
  root to: "events#index"
end
