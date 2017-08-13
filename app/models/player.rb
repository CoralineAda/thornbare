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

  validates_presence_of :name
  validates_presence_of :color

  def color_value
    COLORS[self.color.to_sym]
  end
end
