# frozen_string_literal: true

class Player
  attr_reader :hp, :position

  def initialize position:, hp: 2
    @hp = hp
    @position = position
    @mines = 0
  end

  def alive?
    @hp.positive?
  end

  def collect_mine
    @mines += 1
  end

  def damage
    @hp -= 1
    alive?
  end

  def draw
    puts "🪖  #{alive? ? '🛡' : '☠'} #{@hp}"
    puts "🗃 inventory\n 💣: #{@mines}"
    puts "⚑ objective: #{@goal}"
    # 🛠 - tools to disasemble mines
  end

  def set_goal mines_total:
    @goal ||= mines_total - @hp + 3
  end
end
