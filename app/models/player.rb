class Player < ApplicationRecord

  COLORS = {
    light_red: "#d46a6a",
    dark_red: "#801515",
    light_blue: "#669999",
    dark_blue: "#0d4d4d",
    teal: "#407f7f",
    light_green: "#55aa55",
    dark_green: "#116611",
    light_brown: "#d49a6a",
    dark_brown: "#804515"
  }

  belongs_to :game
  has_many :resources, dependent: :destroy
  has_many :allies, dependent: :destroy
  has_many :distractions, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :color

  after_create :set_initial_resources

  scope :successful, -> { where(success: true) }
  scope :active, -> { where(has_entered_sewers: false) }
  default_scope { order(:created_at) }

  def can_enter_sewers?
    self.times_around_the_board >= Game::MINIMUM_TRIPS_TO_ENABLE_ENDGAME
  end

  def color_value
    COLORS[self.color.to_sym]
  end

  def move(squares)
    update_attribute(:position, self.position + squares)
  end

  private

  def set_initial_resources
    3.times do
      resources.create(value: rand(4) + 1)
    end
  end

end
