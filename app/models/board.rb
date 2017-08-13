class Board

  SQUARE_OFFSET = 90

  def self.coords(position)
    case position
    when 0..10
      [0, (10 - position) * SQUARE_OFFSET]
    when 11..20
      [(position - 10) * SQUARE_OFFSET, 0]
    when 21..30
      [10 * SQUARE_OFFSET, (position - 20) * SQUARE_OFFSET]
    when 31..40
      [(40 - position) * SQUARE_OFFSET, 10 * SQUARE_OFFSET]
    end
  end

end
