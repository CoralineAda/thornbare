class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_player
    @current_player ||= Player.find(session[:player_id])
  end

end
