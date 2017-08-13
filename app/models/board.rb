class Board

  SQUARE_OFFSET = 90

  def self.coords(position)
    case position
    when 0..8
      [position * SQUARE_OFFSET, 0]
    when 9..16
      [8 * SQUARE_OFFSET, (position - 8) * SQUARE_OFFSET]
    when 17..24
      [(24 - position) * SQUARE_OFFSET, 8 * SQUARE_OFFSET]
    when 25..32
      [0, (32 - position) * SQUARE_OFFSET]
    end
  end

end
