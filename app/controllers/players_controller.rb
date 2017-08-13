class PlayersController < ApplicationController

  before_action :scope_game

  def new
    @player = Player.new(game: @game)
  end

  def create
    if player = Player.create(name: player_params[:name], color: player_params[:color], game: @game)
      session[:player_id] = player.id
      redirect_to @game
    else
      render :new
    end
  end

  private

  def player_params
    params[:player]
  end

  def scope_game
    @game = Game.find(params[:game_id])
  end

end
