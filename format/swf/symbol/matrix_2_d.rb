#TODO: i'm sure iOS has a good matrix class? wrapper? just use the one that's there?

class Matrix2D

  attr_accessor :a, :b, :c, :d, :tx, :ty

  def initialize(a=1, b=0, c=0, d=1, tx=0, ty=0)
    @a, @b, @c, @d, @tx, @ty = a,b,c,d,tx,ty
  end
end