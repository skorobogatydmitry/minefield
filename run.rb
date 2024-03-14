#!/usr/bin/env ruby

require 'io/console'
require 'tty-reader'

FIELD_SIZE = 0...10
MINES_PROB = 0.2

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
      has_mine ? 'X' : num_mines_around.zero? ? ' ' : num_mines_around
    else
      '▒'
    end
  end

  def eql? other
    @x.eql?(other.x) && @y.eql?(other.y)
  end
end

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

    @cursor = Cursor::new
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
    puts "\e[H\e[2J#{score}\n┏#{'-' * (FIELD_SIZE.last + 2)}┓   Brochure in your pocket tells:"
    each_dot { |dot|
      print "┃ " if dot.y.zero?

      print (dot.eql?(@cursor) && @cursor.is_revealed ? @cursor : dot).to_char

      print " ┃ #{dot.x}   #{controls[dot.x]}\n" if dot.y.eql? FIELD_SIZE.max

    }
    puts "┗#{'-' * (FIELD_SIZE.last + 2)}┛"
    puts controls[FIELD_SIZE.last] if controls.size > FIELD_SIZE.size
  end

  def score
    "#{mines_revealed} mines out of #{mines_total} are in your bag "
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

  def turn
    expect_mine = get_cmd
    expect_mine.nil? ? self : reveal(get_dot(x:@cursor.x, y:@cursor.y), expect_mine:)
  end

  def reveal dot, expect_mine: false
    return self if dot.is_revealed

    dot.is_revealed = true
    if dot.has_mine
      if expect_mine
        return self
      else
        @cursor.is_revealed = true
        draw
        puts "You are torn apart by a mine\n  ... last thing you see is another drop bot piercing clouds"
        exit 1
      end
    else
      if expect_mine
        new_field = Field.new
        new_field.draw
        puts "You dug the ground for the whole day, now it's a field on the other side of the world!"
        puts "... any key to look around"
        TTY::Reader.new.read_keypress
        return new_field
      end
      if dot.num_mines_around.zero?
        each_dot_around(dot) { |neigh| reveal(neigh) unless neigh.is_revealed }
      end
    end
    self
  end

  def controls
    [
      '* arrows to navigate',
      '* Space to reveal a cell',
      '* Enter to claim a mine',
      '* q to quit the mission'
    ]
  end

  def get_cmd
    expect_mine = nil
    case TTY::Reader.new.read_keypress(nonblock:true, echo:false)
    when 'q'
      puts "You cowardly flew away on jetpack back to your spacecraft"
      exit 0
    when "\n" then expect_mine = true
    when " " then expect_mine = false
    when "\e[A" then @cursor.up
    when "\e[B" then @cursor.down
    when "\e[C" then @cursor.right
    when "\e[D" then @cursor.left
    end
    return expect_mine
  end
end

field = Field::new

loop {
  field.draw
  field = field.turn
  if field.no_mines_left?
    field.draw
    puts "You found all mines, princess Peach is all yours!"
    exit 0
  end
  sleep 0.4
}
