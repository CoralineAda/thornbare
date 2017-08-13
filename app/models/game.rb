class Game < ApplicationRecord

  before_create :set_name

  has_many :players, dependent: :destroy

  def available_colors
    colors = Player::COLORS.keys.map(&:to_s)
    player_colors = self.players.map(&:color)
    colors - player_colors
  end

  private

  def set_name
    self.name = [Faker::Lovecraft.word.capitalize, Faker::Lovecraft.location, rand(1000)].join(' ')
  end

end
