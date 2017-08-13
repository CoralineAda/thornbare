Rails.application.routes.draw do

  root "games#index"

  resources :games do
    get :start, to: :play
    resources :players
  end

end
