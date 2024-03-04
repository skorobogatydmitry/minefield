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
  def initialize
    @array = FIELD_SIZE.collect { |x| FIELD_SIZE.collect { |y|
      d = Dot::new x:,y:, has_mine: rand(0...(1.0 / MINES_PROB).to_i).zero?
    }}

    each_dot { |dot|
      unless dot.has_mine
        dot.num_mines_around = each_dot_around(dot).select(&:has_mine).size
      end
    }
  end

  def each_dot
    @array.inject([]){ |sum, el| sum += el }.each{ |dot| yield dot if block_given? }
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
    puts "\e[H\e[2J#{score}\n   #{FIELD_SIZE.to_a.join}\n#{'-' * (FIELD_SIZE.last + 6)}"
    each_dot { |dot|
      if dot.y.zero?
        print "#{dot.x} |"
      end

      print dot.to_char

      if dot.y.eql? FIELD_SIZE.last - 1
        print "| #{dot.x}"
      end

      print "\n" if dot.y.eql? FIELD_SIZE.last - 1
    }
    puts '-' * (FIELD_SIZE.last + 6)
  end

  def score
    "Mines (revealed / total): #{mines_revealed} / #{mines_total}"
  end

  def mines_revealed
    each_dot.select { |d| d.is_revealed && d.has_mine }.count
  end

  def mines_total
    each_dot.select { |d| d.has_mine }.count
  end

  def no_mines_left?
    each_dot { |dot| return false if (dot.has_mine && !dot.is_revealed) }
    return true
  end

  def reveal x:, y:, expect_mine: false
    return if x.nil?

    dot = get_dot(x:, y:)
    return self if dot.is_revealed

    dot.is_revealed = true
    if dot.has_mine
      if expect_mine
        return self
      else
        draw
        puts "Your arms are flying #{rand 1..4} meters in the air!"
        exit 1
      end
    else
      if expect_mine
        new_field = Field.new
        new_field.draw
        puts "You dug the ground for the whole day, now it's a field on the other side of the world!"
        puts "... and key to look around"
        gets
        return new_field
      end
      if dot.num_mines_around.zero?
        each_dot_around(dot) { |neigh| reveal(x: neigh.x, y: neigh.y) unless neigh.is_revealed }
      end
    end
    self
  end
end

def get_coords
  print "Enter cell to reveal (x y [m]): "
  coord = gets.strip
  x, y, expect_mine = coord.split(' ')
  x = x.to_i
  y = y.to_i
  expect_mine = expect_mine ? true : false
  unless FIELD_SIZE.include?(x) && FIELD_SIZE.include?(y)
    puts "Coordinates '#{coord}' are wrong, both numbers should be within #{FIELD_SIZE}"
    return {x: nil, y: nil}
  end
  {x: x, y: y, expect_mine: expect_mine}
end

field = Field::new

loop {
  field.draw
  field = field.reveal **get_coords
  if field.no_mines_left?
    puts "You found all mines, princess Peach is all yours!"
    exit 0
  end
}
