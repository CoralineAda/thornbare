Rails.application.routes.draw do

  root "games#index"

  resources :games do
    get :start, to: :play
    post :roll_to_move, to: :roll_to_move
    post :end_turn, to: :end_turn
    post :draw_card, to: :draw_card
    resources :players
  end

  mount ActionCable.server, at: '/cable'

end
