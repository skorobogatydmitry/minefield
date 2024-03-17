#!/usr/bin/env ruby

require 'io/console'
require 'tty-reader'

require_relative 'dot'
require_relative 'cursor'
require_relative 'player'

FIELD_SIZE = 0...20
MINES_PROB = 0.2

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

    @player = Player::new position: Cursor::new
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

      print (dot.eql?(@player.position) && @player.position.is_revealed ? @player.position : dot).to_char

      print " ┃ #{dot.x}   #{controls[dot.x]}\n" if dot.y.eql? FIELD_SIZE.max

    }
    puts "┗#{'-' * (FIELD_SIZE.last + 2)}┛"
    puts controls[FIELD_SIZE.last..] if controls.size > FIELD_SIZE.size
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
    expect_mine.nil? ? self : reveal(get_dot(x:@player.position.x, y:@player.position.y), expect_mine:)
  end

  def reveal dot, expect_mine: false
    return self if dot.is_revealed

    dot.is_revealed = true
    if dot.has_mine
      if expect_mine
        return self
      else
        @player.position.is_revealed = true
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
    when "\e[A" then @player.position.up
    when "\e[B" then @player.position.down
    when "\e[C" then @player.position.right
    when "\e[D" then @player.position.left
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
