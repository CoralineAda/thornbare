Rails.application.routes.draw do

  root "games#index"

  get :rules, controller: :rules, to: :rules
  get :background, controller: :rules, to: :background

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
    post :final_encounter, to: :final_encounter
    post :the_end, to: :the_end
    post :select_trading_partner, to: :select_trading_partner
    post :select_cards_to_trade, to: :select_cards_to_trade
    post :do_trade_cards, to: :do_trade_cards
    post :cancel_trade_cards, to: :cancel_trade_cards

    resources :players
  end

  mount ActionCable.server, at: '/cable'

end
