class GamesController < ApplicationController

  before_action :scope_game, except: [:index, :create]
  before_action :scope_players, except: [:index, :create]

  def index
    @games = Game.all
  end

  def create
    @game = Game.create
    redirect_to @game
  end

  def show
  end

  def start
    @game.update_attributes(round: 0, turn: 0)
    @current_player = @players[0]
    @current_space = Space.find_by(position: @current_player.position)
    @spaces = Space.all
    render :board
  end

  def next_turn
    if @game.turn == @game.players.count
      @game.update_attributes(round: @game.round + 1, turn: 0)
      @current_player = @players[0]
      @current_space = Space.find_by(position: @current_player.position)
    else
      @game.update_attributes(turn: @game.turn + 1)
      @current_player = @players[@game.turn]
      @current_space = Space.find_by(position: @current_player.position)
    end
    @spaces = Space.all
    render :board
  end

  def roll_to_move
    render json: { "result": rand(5) + 1 }
  end

  def draw_card
    card = @game.draw_card(@current_player)
    render json: { "card": "#{card.name}_#{card.value}" }
  end

  def next_turn
    @game.next_turn
  end

  private

  def scope_game
    id = params[:id] || params[:game_id]
    @game = Game.find(id)
  end

  def scope_players
    @players = @game.players
    @current_player = @players[@game.turn]
  end

end
