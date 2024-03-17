# frozen_string_literal: true

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
      if has_mine
        '💣'
      else
        num_mines_around.zero? ? ' ' : num_mines_around
      end
    else
      '▒'
    end
  end

  def eql? other
    @x.eql?(other.x) && @y.eql?(other.y)
  end

  def overlayed_by other
    eql?(other) && other.is_revealed ? other : self
  end
end
