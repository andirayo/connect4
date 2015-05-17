# encoding: utf-8

require_relative 'models/position'


# Analyze a C4 (8x8) position
p = Position.new
p.add_stone( D )
p.add_stone( D )
p.add_stone( D )
p.add_stone( E )
p.add_stone( D )
p.add_stone( E )
p.add_stone( A )
p.add_stone( E )
p.add_stone( E )
p.add_stone( E )
p.add_stone( B )
p.add_stone( C )

print p.inspect(false); print '-'*40, "\n"; print p.analyze(true); print '#'*40, "\n"

