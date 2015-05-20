# encoding: utf-8

require_relative 'connect4'
require_relative 'cell'


class Position
  attr_accessor :moves
  attr_reader :board
  attr_reader :cells
  attr_reader :possible_cells   # to play
  attr_reader :fill_heights
  attr_reader :total_stones
  attr_reader :last_column, :last_row
  attr_reader :game_over, :winner


  def initialize
    @board              = Hash.new {|h,k|h[k]=Hash.new}
    (1..Connect4::COLUMNS).each do |col|
      (1..Connect4::ROWS).each do |row|
        @board[col][row] = Cell.new
      end #each
    end #each

    @cells              = []
    @moves              = ''
    @possible_cells     = []  # Set.new
    @fill_heights       = Hash[(1..Connect4::COLUMNS).zip(Array.new(Connect4::COLUMNS,0))]
    @total_stones       = 0
    @last_column        = false
    @last_row           = false

    @game_over          = false
    @winner             = nil

    initialize_cells
  end #initialize

  def initialize_cells
    (1..Connect4::COLUMNS).each do |col|
      @board[col][1].immediate  = true
      @possible_cells           << @board[col][1]

      (1..Connect4::ROWS).each do |row|
        @cells                << @board[col][row]
        @board[col][row].col  = col
        @board[col][row].row  = row

        neighbors_bottom_up   = []
        neighbors_horizontal  = []
        neighbors_top_down    = []
        (-3..+3).each do |diff|
          neighbors_bottom_up   << @board[col+diff][row+diff]   if (1..Connect4::COLUMNS).include?(col+diff)  &&  (1..Connect4::ROWS).include?(row+diff)
          neighbors_horizontal  << @board[col+diff][row]        if (1..Connect4::COLUMNS).include?(col+diff)
          neighbors_top_down    << @board[col+diff][row-diff]   if (1..Connect4::COLUMNS).include?(col+diff)  &&  (1..Connect4::ROWS).include?(row-diff)
        end #each

        @board[col][row].set_neighbors_bottom_up(   neighbors_bottom_up )   if 4 <= neighbors_bottom_up.size
        @board[col][row].set_neighbors_horizontal(  neighbors_horizontal )  if 4 <= neighbors_horizontal.size
        @board[col][row].set_neighbors_top_down(    neighbors_top_down )    if 4 <= neighbors_top_down.size

        @board[col][row].cell_below   = @board[col][row-1]  if 0 < row
        if row < Connect4::ROWS
          @board[col][row].cell_above = @board[col][row+1]

          if 3 <= row
            @board[col][row].set_neighbors_vertical(  (row-2..row+1).map {|r| @board[col][r]}  )
          end #if
        end #if
      end #each
    end #each
  end #initialize_cells

  # column from 1-8 or A to H
  def add_stone( col )
    col = col.is_a?(Fixnum)  ?  col  :  letter_to_number(col)

    return false  if game_over
    return false  unless (1..Connect4::COLUMNS).include?( col )
    return false  if Connect4::ROWS         <= @fill_heights[col]

    @fill_heights[col]              += 1

#p (col + (next_player ? 64 : 96)).chr
    begin
      @board[col][@fill_heights[col]] << next_player
    rescue => exception
      print "\n"
      p exception
      p moves
      print '-'*40, "\n"; print analyze(true); print '#'*40, "\n"
    end #begin-resuce

    @moves                          << (col + (next_player ? 64 : 96)).chr
    @last_column                    = col
    @last_row                       = @fill_heights[col]
    @possible_cells.delete( @board[col][@fill_heights[col]] )
    @possible_cells                 << @board[col][@fill_heights[col]+1]  if Connect4::ROWS > @fill_heights[col]

    @total_stones                   += 1

    if @board[col][@fill_heights[col]].winner
      @game_over    = true
      @winner       = last_player
    elsif Connect4::TOTAL_CELLS  <= @total_stones
      @game_over    = true
      @winner       = Connect4::DRAW
    end #if

    return true
  end #add_stone
  #
  def add_stones( str )
    str.chars.each( &method(:add_stone) )
  end #add_stones


  def threats( player = nil )
    @cells.select {|c| c.threat?(player)}
  end #threats

  def checks
    @possible_cells.select(&:check?)
  end #checks

  def nogos( player = nil )
    @possible_cells.select {|c| c.nogo?(player)}
  end #nogos

  def playable
    @possible_cells.reject {|c| c.nogo?(next_player)}
  end #playable

  def letter_to_number( char )
    # ASCii code for "a" is 97
    char.downcase.ord - 96
  end #letter_to_number

  def next_player
    Connect4::PLAYERS[@total_stones % 2]
  end #next_player

  def last_player
    Connect4::PLAYERS[(@total_stones+1) % 2]
  end #last_player

  def last_cell
    @board[@last_column][@last_row]
  end #last_cell

  def hash
    @board.values.map(&:values).map{|c| c.map(&:hash_stone)}.map(&:join).join
  end #hash

  def ==( other )
    hash == other.hash
  end #==

  def threats( player = nil )
    @cells.select {|c| c.threat?(player)}
  end #threats

  def inspect( nice = true, spaces = 1 )
    (Connect4::ROWS).downto(1).map do |row|
      @board.values.map {|col| col[row].inspect(nice)}.join(' '*spaces) + "\n"
    end.join
  end #inspect

  def analyze( nice = true, spaces = 1 )
    output  = inspect( nice, spaces )

    if game_over
      output  += sprintf "The game is over.\n"
      output  += sprintf "%s has won the game with cell %s\n", Connect4::PLAYER_TO_COLOR[winner], cells.select(&:winner).first

    else
      output  += sprintf "Next player: %s\n", Connect4::PLAYER_TO_COLOR[next_player]
      if checks.empty?
        output  += sprintf "No Checks at current position.\n"
      else
        output  += sprintf "Checks: %s\n", checks.map(&:to_s).join(', ')

        if (options = checks.select {|c| c.threat?(next_player)}).empty?
          output  += sprintf "Player %s has to play cell %s\n", Connect4::PLAYER_TO_COLOR[next_player], checks.first.to_s
        else
          output  += sprintf "Player %s can win with cell %s\n", Connect4::PLAYER_TO_COLOR[next_player], options.first.to_s
        end #if
      end #if-else
      output  += sprintf "Threats: %s\n", threats.map(&:to_s).join(', ')
      unless nogos.empty?
        output  += sprintf "Player %s must not play cell%s %s\n", Connect4::PLAYER_TO_COLOR[next_player], 1 < nogos.size  ?  's'  :  '', nogos.map(&:to_s).join(', ')
      end #unless
      output  += sprintf "Player %s can play here: %s\n", Connect4::PLAYER_TO_COLOR[next_player], playable.map(&:to_s).sort.join(', ')
    end #if

    output
  end #analyze


  alias_method :===, :==
  alias_method :move, :add_stone
  alias_method :next_turn, :next_player
  alias_method :last_turn, :last_player
end #Position


