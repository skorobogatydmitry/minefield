class Dot
  attr_reader :has_mine, :x, :y
  attr_accessor :is_revealed, :num_mines_around
  def initialize x:, y:, has_mine:
    @x = x
    @y = y
    @has_mine = has_mine
    @is_revealed = false
    @num_mines_around = 0
  end

  def to_char
    if is_revealed
      has_mine ? '💣' : num_mines_around.zero? ? ' ' : num_mines_around
    else
      '▒'
    end
  end

  def eql? other
    @x.eql?(other.x) && @y.eql?(other.y)
  end
end
