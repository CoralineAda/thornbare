module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = find_user
    end

    private

    def find_user
      Player.where(cookies.encrypted[:player_id]).first
    end

  end
end
