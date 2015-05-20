# encoding: utf-8

require_relative 'models/position'
require_relative 'analyzer'

# Analyze a C4 (8x8) position
p = Position.new
#p.add_stone( D )
#p.add_stone( D )
#p.add_stone( D )
#p.add_stone( E )
#p.add_stone( D )
#p.add_stone( E )
#p.add_stone( A )
#p.add_stone( E )
#p.add_stone( E )
#p.add_stone( E )
#p.add_stone( B )
#p.add_stone( C )
p = Position.new
p.add_stones('ddddddefbccccfefffafeeeffd')
#p.add_stones('DeEaAaAaAcCbBaBbHhHhBcCeHhGgB')
#p.add_stones('DeEaAaAaAcCbBaBbHhHhBcCeHhGgBbG')

print p.inspect(false); print '-'*40, "\n"; print p.analyze(true); print '#'*40, "\n"
printf "Position-hash: %s\n", p.hash
printf "Moves so far : %s\n", p.moves
print '='*40, "\n"


p.moves       = ''
a             = Analyzer.new
winner        = a.play( p )
#winner,moves  = a.play( p )

print "\n"
printf "Position analyzed: %s\n", a.calculated.size
printf "Winner: %s (%s)\n", Connect4::PLAYER_TO_COLOR[winner], winner
#printf "Moves: %s\n", moves

=begin
JL-game:
    F7-c5-E3!-e4!-E5!-e6!-C6!-e7-F8!-a2->loose
C5-g1-E3!-e4!-E5!-c6-E6!-f7!-F8!-e7-C7->draw
G1-c5-E3!-e4!-E5!-e6-C6!-f7-F8!-e7->loose
E3-e4!-E5!-c5-F7-e6!-C6!-e7-F8!-a2->loose
E3-e4!-E5!-c5-E6-f7!-f8!-e7->loose or draw
E3-e4!-E5!-c5-H1-d7-E6-f7!-F8!-e7-E8-h2->loose
E3-e4!-E5!-c5-F7-e6!-C6!-e7-F8!-a2->loose
E3-e4!-E5!-c5-C6-f7-F8!-c7-D7-d8-H1-h2-C8-a2-H3->draw
E3-e4!-E5!-c5-C6-f7-F8!-c7-D7-d8-H1-c8-H2->win

H1-c5-E6-e7-H2-e8-D8->loose
H1-c5-E6-e7-E8-h2-D8

=end