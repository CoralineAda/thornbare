Rails.application.routes.draw do

  root "games#index"

  resources :games do
    post :start, to: :play
    resources :players
  end

end
