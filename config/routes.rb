Rails.application.routes.draw do

  root "games#index"

  resources :games do
    get :start, to: :play
    post :roll_to_move, to: :roll_to_move
    post :show_cards, to: :show_cards
    post :end_turn, to: :end_turn
    post :draw_card, to: :draw_card
    post :choose_card, to: :draw_card
    post :show_ally_or_distraction, to: :show_ally_or_distraction
    post :show_rolls, to: :show_rolls
    post :show_outcome, to: :show_outcome
    post :end_encounter, to: :end_encounter
    resources :players
  end

  mount ActionCable.server, at: '/cable'

end
