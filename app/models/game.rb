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
      drawn_card = Card.new(name: "resource", value: card_value)
      player.resources.create(value: drawn_card.value)
    when 2
      drawn_card = Card.new(name: "ally", value: card_value)
      player.allies.create(value: drawn_card.value)
    when 3
      drawn_card = Card.new(name: "distraction", value: card_value)
      player.distractions.create(value: drawn_card.value)
    when 4
      drawn_card = Card.new(name: "encounter", value: card_value)
      encounters.create(value: drawn_card.value)
    end
    drawn_card
  end

  def has_started?
    self.round > 0
  end

  def next_turn
    update_attribute(:turn, self.turn + 1)
  end

  private

  def set_name
    self.name = "#{Faker::Lovecraft.word.capitalize} #{Faker::Lovecraft.location}"
  end

  def card_value
    case rand(10)
    when 0..1; 1
    when 2..3; 2
    when 4..6; 3
    when 7..8; 4
    when 9; 5
    end
  end

end
