# encoding: utf-8


A=1
B=2
C=3
D=4
E=5
F=6
G=7
H=8


class Connect4
  EMPTY   = DRAW        = nil
  YELLOW  = PLAYER1     = true
  RED     = PLAYER2     = false
  PLAYERS               = [YELLOW, RED]
  PLAYER_TO_COLOR       = {YELLOW => 'yellow', RED => 'red', DRAW => 'draw'}

  COLUMNS               = 8
  ROWS                  = 8
  TOTAL_CELLS           = COLUMNS * ROWS

  def self.opponent( stone )
    YELLOW == stone  ?  RED  :  YELLOW
  end #opponent
end #Connect4


