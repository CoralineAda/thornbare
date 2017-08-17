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
  end

  def start
    @this_player = current_player
    render :board
  end

  def roll_to_move
    result = rand(5) + 1
    original_position = @current_player.position
    @current_player.update_attributes!(position: (@current_player.position + result) % 32)
    @current_space = Space.find_by(position: @current_player.position)
    ActionCable.server.broadcast(
      "game_channel",
      {
        players: render_players,
        from_position: original_position,
        to_position: @current_player.position,
        move_result: result
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
      card = @game.draw_card(@current_player)
      ActionCable.server.broadcast(
        "game_channel",
        {
          game: render_game,
          card: "#{card.name}_#{card.value}"
        }
      )
    end
  end

  def end_turn
    @game.next_turn
    if @game.turn == @players.count
      @game.next_round
    end
    @current_player = @players.any? && @players[@game.turn]
    ActionCable.server.broadcast(
      "game_channel",
      {
        game: render_game,
        next_turn: true
      }
    )
  end

  private

  def scope_game
    id = params[:id] || params[:game_id]
    @game = Game.find(id)
  end

  def scope_players
    @players = @game.players
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

  def render_cards
    render partial: "cards", locals: { current_player: @current_player }
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
      card: "ally_1.png"
    }
  end

end
