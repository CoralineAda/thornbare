class GamesController < ApplicationController

  def index
    @games = Game.all
  end

  def create
    @game = Game.create
    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
    @players = @game.players
  end

  def play
  end

end
