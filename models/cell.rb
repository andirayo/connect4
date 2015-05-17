# encoding: utf-8

require_relative 'connect4'
require 'set'


class Cell
  attr_accessor :stone
  attr_accessor :threats
  attr_accessor :immediate
  attr_accessor :winner
  attr_accessor :col, :row
  attr_accessor :cell_above
  attr_reader :neighbors_bottom_up, :neighbors_horizontal, :neighbors_top_down, :neighbors_vertical

  def initialize
    @stone                = Connect4::EMPTY
    @threats              = Set.new
    @immediate            = false
    @winner               = false

    @col                  = nil
    @row                  = nil

    @neighbors_bottom_up  = []  # bottom left to top right
    @neighbors_horizontal = []  # left to right, horizontally
    @neighbors_top_down   = []  # top left to bottom right
    @neighbors_vertical   = []  # below to 1 above
    @cell_above           = nil
  end #initialize

  def set_neighbors_bottom_up( neighbors )
    @neighbors_bottom_up  = neighbors
  end #set_neighbors_bottom_up
  def set_neighbors_horizontal( neighbors )
    @neighbors_horizontal = neighbors
  end #set_neighbors_horizontal
  def set_neighbors_top_down( neighbors )
    @neighbors_top_down   = neighbors
  end #set_neighbors_top_down
  def set_neighbors_vertical( neighbors )
    @neighbors_vertical   = neighbors
  end #set_neighbors_vertical


  def <<( stone )
    @stone                = stone
    @immediate            = false
    @winner               = true    if @threats.include?( @stone )
    @cell_above.immediate = true    if @cell_above

    @threats.clear
    analyze_neighbors   unless @winner
  end #<<

  def analyze_neighbors
    analyze_neighbors_generic( @neighbors_bottom_up )
    analyze_neighbors_generic( @neighbors_horizontal )
    analyze_neighbors_generic( @neighbors_top_down )
    analyze_neighbors_generic( @neighbors_vertical )
  end #analyze_neighbors

  def analyze_neighbors_generic( neighbor_cells )
    (0..neighbor_cells.size-4).each do |start|
      in_a_row, potential_threat =
          neighbor_cells[start..start+3].reduce([0,nil]) do |(in_a_row,potential_threat), neighbor_cell|
#          printf "in a row: %s, potential threat: %s\n", in_a_row,potential_threat
            case neighbor_cell.stone
              when !@stone;   break             # opponent has taken that cell
              when @stone;    in_a_row  += 1
              when nil;       potential_threat  = neighbor_cell
            end #case
            [in_a_row,potential_threat]
          end #reduce

      # when breaking out of reduce, in_a_row will be nil
      next  unless in_a_row

      raise 'Weird number of stones in a row around cell!'  if 3 < in_a_row
      potential_threat.threats << @stone                    if 3 == in_a_row
    end #each
  end #analyze_neighbors_generic


  def threat?( player = nil )
    return ! @threats.empty?  if player.nil?
    return @threats.include?( player )
  end #threat?

  def check?
    threat?  &&  @immediate
  end #check?

  def inspect(nice = true)
    case @stone
      when Connect4::YELLOW;  nice  ?  '●'  :  '1'    # '⚫'  '🔵'
      when Connect4::RED;     nice  ?  '○'  :  '2'    # '⚪'  '🔴'
      when Connect4::EMPTY
        nice  ?  (threat?  ?  (check?  ?  '‼'  :  (0 == row % 2  ?  '!'  :  '?'))  :  '◟')  :  '0'
    end #case
  end #inspect

  def to_s
    (@col+64).chr + @row.to_s
  end #to_s
end #Cell


