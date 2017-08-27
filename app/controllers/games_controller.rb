class GamesController < ApplicationController

  before_action :scope_game, except: [:index, :create, :new]
  before_action :scope_players, except: [:index, :create, :new]
  before_action :scope_spaces, except: [:index, :create, :new, :show]

  def index
    @games = Game.all
  end

  def create
    @game = Game.create
    @game.update_attributes(round: 0, turn: 0)
    redirect_to @game
  end

  def show
    @current_player = current_player
  end

  def start
    @this_player = @game.players[@game.turn]
    @card = Card.new(name: "encounter", value: 3)
    render :board
  end

  def roll_to_move
    result = rand(5) + 1
    original_position = @current_player.position
    if @current_player.position + result >= 32
      @current_player.resources.create(value: @game.card_value)
      @current_player.update_attribute(:times_around_the_board,  @current_player.times_around_the_board + 1)
    end
    @current_player.update_attributes(position: (@current_player.position + result) % 32)
    @current_space = Space.find_by(position: @current_player.position)
    can_trade_cards = @game.players.active.where(position: @current_player.position).count > 1
    ActionCable.server.broadcast(
      "game_channel",
      {
        players: render_players,
        from_position: original_position,
        to_position: @current_player.position,
        move_result: result,
        can_trade_cards: can_trade_cards
      }
    )
  end

  def show_cards
    ActionCable.server.broadcast(
      "game_channel",
      {
        cards: render_cards
      }
    )
  end

  def draw_card
    if @current_player.position % 4 == 0
      @card = @game.draw_resource(@current_player)
    else
      @card = @game.draw_card(@current_player)
    end
    if @card.name == "encounter"
      session[:encounter_value] = @card.value
      ActionCable.server.broadcast(
        "game_channel",
        {
          encounter: render_game,
          card: "#{@card.name}_#{@card.value}",
          card_type: @card.name,
          value: @card.value,
          next_step: @current_player.allies.any? || @current_player.distractions.any? ? "choose_card" : "show_rolls"
        }
      )
    else
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render_game,
          card: "#{@card.name}_#{@card.value}"
        }
      )
    end
  end

  def select_trading_partner
    ActionCable.server.broadcast(
      "game_channel",
      {
        game: render(partial: "select_trading_partner", locals: {
          game: @game,
          current_player: @current_player
        }),
        trading_cards: true
      }
    )
  end

  def select_cards_to_trade
    ActionCable.server.broadcast(
      "game_channel",
      {
        game: render(partial: "trade_cards", locals: {
          game: @game,
          current_player: @current_player,
          trading_partner: params[:trading_partner]
        }),
        trading_cards: true,
        trading_partner: params[:trading_partner]
      }
    )
  end

  def do_trade_cards
    traded_player = @game.players.find_by(name: params[:trading_partner])
    card_value = params[:chosen_value].to_i
    if params[:chosen_card] == "resource"
      @current_player.resources.find{ |r| r.value == card_value }.destroy
      traded_player.resources.create(value: card_value)
      card = Card.new(name: "resource", value: card_value)
    elsif params[:chosen_card] == "ally"
      @current_player.allies.find{ |r| r.value == card_value }.destroy
      traded_player.allies.create(value: card_value)
      card = Card.new(name: "ally", value: card_value)
    elsif params[:chosen_card] == "distraction"
      @current_player.distractions.find{ |r| r.value == card_value }.destroy
      traded_player.distractions.create(value: card_value)
      card = Card.new(name: "distraction", value: card_value)
    end
    ActionCable.server.broadcast(
      "game_channel",
      {
        game: render(
          partial: "traded_cards", locals: {
            traded_player: traded_player.name,
            traded_card: card
          }
        ),
        traded_cards: true
      }
    )
  end

  def choose_card
    ActionCable.server.broadcast(
      "game_channel",
      {
        encounter: render(
          partial: "choose_card",
          locals: {
            current_player: @current_player,
            card: Card.new(name: "encounter", value: session[:encounter_value])
          }
        ),
        encounter_in_progress: true,
        step: "choose_card",
        encounter_value: session[:encounter_value],
      }
    )
  end

  def cancel_trade_cards
    @card = Card.new
    ActionCable.server.broadcast(
      "game_channel",
      {
        game: render_game,
        trade_cards_complete: true,
        can_draw_card: true,
        can_trade_card: true
      }
    )
  end

  def final_encounter
    @card = Card.new(name: "encounter", value: Game::FINAL_ENCOUNTER_VALUE)
    session[:encounter_value] = @card.value
    ActionCable.server.broadcast(
      "game_channel",
      {
        encounter: render_game,
        card: "#{@card.name}_#{@card.value}",
        card_type: @card.name,
        value: @card.value,
        next_step: @current_player.allies.any? || @current_player.distractions.any? ? "choose_card" : "show_rolls"
      }
    )
  end

  def show_ally_or_distraction
    session[:ally_or_distraction] = { name: params[:chosen_card], value: params[:chosen_value] }
    ActionCable.server.broadcast(
      "game_channel",
      {
        encounter: render(
          partial: "show_ally_or_distraction",
          locals: {
            card: Card.new(name: session[:ally_or_distraction][:name], value: session[:ally_or_distraction][:value]),
            card_type: session[:ally_or_distraction][:name]
          }
        ),
        encounter_in_progress: true,
        step: "show_ally_or_distraction",
      }
    )
  end

  def show_rolls
    additional_dice = 0
    dice_reduction = 0
    if session[:ally_or_distraction] && session[:ally_or_distraction]['name'] == "ally"
      additional_dice = session[:ally_or_distraction]['value'].to_i
    elsif session[:ally_or_distraction] && session[:ally_or_distraction]['name'] == "distraction"
      dice_reduction = session[:ally_or_distraction]['value'].to_i
      if session[:encounter_value] - dice_reduction < 1
        dice_reduction += session[:encounter_value] - dice_reduction - 1
      end
    end
    player_result = Game.roll_dice(1 + additional_dice)
    opponent_result = Game.roll_dice(session[:encounter_value] - dice_reduction)
    if player_result == opponent_result
      outcome = "draw"
    elsif player_result > opponent_result
      outcome = "success"
    else
      outcome = "failure"
    end
    session[:outcome] = outcome
    ActionCable.server.broadcast(
      "game_channel",
      {
        encounter: render(
          partial: "show_rolls",
          locals: {
            player_result: player_result,
            opponent_result: opponent_result
          }
        ),
        encounter_in_progress: true,
        outcome: outcome,
        step: "show_rolls"
      }
    )
  end

  def show_outcome
    if session[:outcome] == "failure"
      resources_lost = Resource.lose(@current_player.resources.map(&:value), session[:encounter_value])
      resources_lost[:remove].each do |value|
        @current_player.resources.find_by(value: value).destroy
      end
      resources_lost[:change].each do |value|
        @current_player.resources.create(value: value)
      end

      if lost_card = session[:ally_or_distraction]
        if lost_card['name'] == "ally" && params[:outcome] == "failure"
          if ally_to_lose = @current_player.allies.find{ |ally| ally.value == lost_card['value'].to_i }
            ally_to_lose.destroy
          end
        elsif lost_card['name'] == "distraction"
          @current_player.distractions.find{ |distraction| distraction.value == lost_card['value'].to_i }.destroy
        end
      end
    end

    if session[:encounter_value] == Game::FINAL_ENCOUNTER_VALUE
      if session[:outcome] == "success" || session[:outcome] == "draw"
        @current_player.update_attributes(has_entered_sewers: true, success: true)
        ActionCable.server.broadcast(
          "game_channel",
          {
            encounter: render(
              partial: "victory",
              locals: { resource_value: @current_player.resources.map(&:value).sum }
            ),
            encounter_in_progress: true,
            step: "show_outcome",
          }
        )
      else
        @current_player.update_attributes(has_entered_sewers: true, success: false)
        ActionCable.server.broadcast(
          "game_channel",
          {
            encounter: render(
              partial: "failure",
              locals: {}
            ),
            encounter_in_progress: true,
            step: "show_outcome"
          }
        )
      end
    else
      ActionCable.server.broadcast(
        "game_channel",
        {
          encounter: render(
            partial: "outcome",
            locals: {
              outcome: params[:outcome],
              resources_lost: resources_lost && resources_lost[:remove].sum,
              ally: lost_card && lost_card['name'] == "ally"
            }
          ),
          encounter_in_progress: true,
          step: "show_outcome"
        }
      )
    end
    session[:player_result] = nil
    session[:opponent_result] = nil
    session[:encounter_value] = nil
    session[:ally_or_distraction] = nil
    session[:outcome] = nil
  end

  def end_encounter
    @game.next_turn
    if @game.turn == @players.count
      @game.next_round
    end
    @current_player = @players.any? && @players[@game.reload.turn]
    can_trade_cards = @game.players.active.where(position: @current_player.position).count > 1
    if @game.players.where(has_entered_sewers: true).count == @game.players.count
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render(partial: "the_end", locals: { game: @game }),
          end_game: true
        }
      )
    else
      @card = Card.new
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render_game,
          next_turn: true,
          round: @game.round,
          can_enter_sewers: @current_player.can_enter_sewers?,
          can_trade_cards: can_trade_cards
        }
      )
    end
  end

  def end_turn
    @game.next_turn
    if @game.turn == @players.count
      @game.next_round
    end
    @current_player = @players.active.any? && @players[@game.reload.turn]
    can_trade_cards = @game.players.active.where(position: @current_player.position).count > 1
    if @game.players.where(has_entered_sewers: true).count == @game.players.count
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render(partial: "the_end", locals: { game: @game }),
          end_game: true
        }
      )
    else
      @card = Card.new
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render_game,
          next_turn: true,
          round: @game.round,
          can_enter_sewers: @current_player.can_enter_sewers?,
          can_trade_cards: can_trade_cards
        }
      )
    end
  end

  private

  def scope_game
    id = params[:id] || params[:game_id]
    @game = Game.find(id)
  end

  def scope_players
    @players = @game.players.active
    @current_player = @players.any? && @players[@game.turn]
    @connected_player = current_player || Player.new
  end

  def scope_spaces
    @spaces = Space.all
    @current_space = Space.find_by(position: @current_player.position)
  end

  def render_players
    render partial: "players", locals: {
      players: @players,
      current_player: @current_player
    }
  end

  def render_encounter
    render partial: "encounter", locals: { current_player: current_player, card: @card }
  end

  def render_cards
    render partial: "cards", locals: { current_player: current_player }
  end

  def render_game
    render partial: "game", locals: {
      game: @game,
      players: @players,
      spaces: @spaces,
      current_player: @current_player,
      current_space: @current_space,
      connected_player: @connected_player,
      result: rand(5) + 1,
      card: @card
    }
  end

end
