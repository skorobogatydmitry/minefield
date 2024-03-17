# frozen_string_literal: true

require_relative 'dot'

class Cursor < Dot
  attr_accessor :x, :y

  def initialize
    super x: FIELD_SIZE.to_a.sample, y: FIELD_SIZE.to_a.sample, has_mine: false
    Thread.new {
      loop {
        @is_revealed = !@is_revealed
        sleep 0.5
      }
    }
  end

  def to_char
    is_revealed ? '🪖 ' : '⠀'
  end

  def up
    @x -= 1 if @x.positive?
  end

  def down
    @x += 1 if @x < FIELD_SIZE.max
  end

  def left
    @y -= 1 if @y.positive?
  end

  def right
    @y += 1 if @y < FIELD_SIZE.max
  end
end
