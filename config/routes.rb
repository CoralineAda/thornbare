Rails.application.routes.draw do

  root "games#index"

  resources :games do
    resources :players
  end

end
