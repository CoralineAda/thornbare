class Game < ApplicationRecord

  before_create :set_name

  has_many :players, dependent: :destroy
  has_many :encounters

  def available_colors
    colors = Player::COLORS.keys.map(&:to_s)
    player_colors = self.players.map(&:color).map{ |color| color.downcase.split.join('_') }
    colors - player_colors
  end

  def roll_dice(quantity)
    total = 0
    1..quantity.to_a.each do |die_number|
      total += rand(5) + 1
    end
    total
  end

  def draw_card(player)
    case rand(5)
    when 0..1
      drawn_card = Card.new(name: "resource", value: rand(4) + 1)
      player.resources.create(value: drawn_card.value)
    when 2
      drawn_card = Card.new(name: "ally", value: rand(4) + 1)
      player.allies.create(value: drawn_card.value)
    when 3
      drawn_card = Card.new(name: "distraction", value: rand(4) + 1)
      player.distractions.create(value: drawn_card.value)
    when 4
      drawn_card = Card.new(name: "encounter", value: rand(4) + 1)
      encounters.create(value: drawn_card.value)
    end
    drawn_card
  end

  private

  def set_name
    self.name = "#{Faker::Lovecraft.word.capitalize} #{Faker::Lovecraft.location}"
  end

end
