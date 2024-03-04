#!/usr/bin/env ruby

FIELD_SIZE = 0...9
MINES_PROB = 0.1

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
      has_mine ? '*' : num_mines_around.zero? ? ' ' : num_mines_around
    else
      '#'
    end
  end
end

class Field
  def initialize array:
    @array = array

    each_dot { |dot|
      unless dot.has_mine
        dot.num_mines_around = each_dot_around(dot).select(&:has_mine).size
      end
    }
  end

  def each_dot
    @array.each { |row| row.each { |dot| yield dot }}
  end

  def each_dot_around dot
    dots = []
    (-1..1).each { |dx|
      (-1..1).each { |dy|
        next if dx.zero? && dy.zero?
        neigh = get_dot(x: dot.x + dx, y: dot.y + dy)
        dots << neigh unless neigh.nil?
      }
    }
    dots.each { |d| yield d if block_given? }
  end

  def get_dot x:, y:
    return nil if x < 0 || y < 0
    @array.at(x)&.at(y)
  end

  def draw
    # puts "\e[H\e[2J"
    each_dot { |dot|
      print dot.to_char
      print "\n" if dot.y.eql? FIELD_SIZE.last - 1
    }
  end

  def no_mines_left?
    each_dot { |dot| return false if (dot.has_mine && !dot.is_revealed) }
    return true
  end

  def reveal x:, y:
    return if x.nil?

    dot = get_dot(x:, y:)
    dot.is_revealed = true
    if dot.has_mine
      draw
      puts "Your arms are flying #{rand 1..4} meters in the air!"
      exit 0
    else
      if dot.num_mines_around.zero?
        each_dot_around(dot) { |neigh| reveal(x: neigh.x, y: neigh.y) unless neigh.is_revealed }
      end
    end
  end
end

def get_coords
  print "Enter cell to reveal (x y): "
  coord = gets.strip
  x, y = coord.split(' ').collect &:to_i
  unless FIELD_SIZE.include?(x) && FIELD_SIZE.include?(y)
    puts "Coordinates #{x} / #{y} are wrong, both should be in #{FIELD_SIZE}"
    return {x: nil, y: nil}
  end
  {x: x, y: y}
end

field = Field::new array: FIELD_SIZE.collect { |x| FIELD_SIZE.collect { |y|
  d = Dot::new x:,y:, has_mine: rand(0...(1.0 / MINES_PROB).to_i).zero?
}}

loop {
  field.draw
  field.reveal **get_coords
  if field.no_mines_left?
    puts "You found all mines, princess Peach is all yours!"
    exit 0
  end
}
