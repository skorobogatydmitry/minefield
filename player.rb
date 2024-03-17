class Player
  attr_reader :hp, :position
  def initialize hp: 2, position:
    @hp = hp
    @position = position
    @mines = 0
  end

  def alive?
    @hp > 0
  end

  def collect_mine
    @mines += 1
  end

  def damage
    @hp -= 1
    alive?
  end

  def draw
    puts "🪖  #{alive? ? '❤️' : '☠'} #{@hp}"
    puts "🗃 inventory\n 💣: #{@mines}"
    # 🛡 - protection 🛠 - tools to disasemble mines
  end
end