require_relative 'dot'

class Cursor < Dot
  attr_accessor :x, :y
  def initialize
    super x:FIELD_SIZE.to_a.sample, y:FIELD_SIZE.to_a.sample, has_mine:false
  end

  def to_char
    '?'
  end

  def is_revealed
    @is_revealed = !@is_revealed
  end

  def up
    @x-=1 if @x > 0
  end

  def down
    @x+=1 if @x < FIELD_SIZE.max
  end

  def left
    @y-=1 if @y > 0
  end

  def right
    @y+=1 if @y < FIELD_SIZE.max
  end
end