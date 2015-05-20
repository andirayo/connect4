# encoding: utf-8

require_relative 'models/position'

require 'deep_clone'
require 'set'


class Analyzer
  attr_reader :calculated
  attr_reader :focus_player

  def initialize
    @calculated   = Hash.new
    #@focus_player = focus_player
  end #initialize

  def add_calc( hash, winner )
    @calculated[ hash ] = winner

    print '.'  if 0 == @calculated.size % 1000
  end #add_calc

  def play( position )
    hash  = position.hash

    # position has been analyzed before
    return @calculated[ hash ]  if @calculated[ hash ]
#    return [@calculated[ hash ], position.moves]  if @calculated[ hash ]

    # game is over
    if position.game_over
      add_calc( hash, position.winner )
      return position.winner
#      return [position.winner, position.moves]
    end #unless


    next_player = position.next_player
    last_player = position.last_player
    checks      = position.checks

    # there are checks on the board
    unless checks.empty?
      # next_player has to prevent immediate loss
      if checks.select {|c| c.threat?(next_player)}.empty?
        position.add_stone( checks.first.col )
        winner              = play( position )
#        winner, moves       = play( position )
        add_calc( hash, winner )
        return winner
#        return [winner, moves || position.moves]
      # next_player can win immediately
      else
        add_calc( hash, next_player )
        return next_player
#        return [next_player, position.moves]
      end #if
    end #unless


    playable      = position.playable

    # no more moves (without immediately loosing) for next_player
    if playable.empty?
      add_calc( hash, last_player )
      return last_player
#      return [last_player, position.moves]
    end #if


    draw_possible = false
    pos           = nil
    moves         = nil
    playable.reverse.each do |cell|
      pos         = DeepClone.clone( position )
      pos.add_stone( cell.col )
      winner      = play( pos )
#      winner, mos = play( pos )

      if next_player == winner
        add_calc( hash, next_player )
        return next_player
#        return [next_player, mos]
      elsif Connect4::DRAW == winner
        draw_possible = true
#        moves         = mos
      end #if
    end #each

    if draw_possible
      add_calc( hash, Connect4::DRAW )
      return Connect4::DRAW
#      return [Connect4::DRAW, moves]
    else
      add_calc( hash, last_player )
      return last_player
#      return [last_player, pos.moves]
    end #if
  end #play
end #Analyzer

