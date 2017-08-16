class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_player
    Player.where(id: cookies.signed[:player_id]).first
  end

end
