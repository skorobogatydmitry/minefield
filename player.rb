class Player
  attr_reader :hp, :position
  def initialize hp: 1, position:
    @hp = hp
    @position = position
  end

  def alive?
    @hp > 0
  end
end