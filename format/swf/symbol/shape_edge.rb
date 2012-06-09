#from Shape.hx

class ShapeEdge
  
  attr_accessor :fill_style
  attr_accessor :is_quadratic
  attr_accessor :cx
  attr_accessor :cy
  attr_accessor :x0
  attr_accessor :x1
  attr_accessor :y0
  attr_accessor :y1
  
  def as_command
    if is_quadratic
      return Proc.new{ |graphics| graphics.curve_to(@cx,@cy,@x1,@y1) }
    else
      return Proc.new{ |graphics| graphics.line_to(@x1,@y1) }
    end
  end

  def connects(edge)
    fill_style == edge.fill_style && (@x1 - edge.x0).abs < 0.00001 && (@y1 - edge.y0).abs < 0.00001
  end
	
	def self.curve(style, x0, y0, cx, cy, x1, y1)

	  result = ShapeEdge.new	  
	  result.x0 = x0
		result.y0 = y0
		result.cx = cx
		result.cy = cy
		result.x1 = x1
		result.y1 = y1
		result.is_quadratic = true
		
    result
	end
	
	def dump
	  puts (x0 + "," + y0 + " -> " + x1 + "," + y1 + " (" + fillStyle + ")" );
	end

  def self.line(style, x0, y0, x1, y1)
    result = ShapeEdge.new

		result.fill_style = style
		result.x0 = x0
		result.y0 = y0
		result.x1 = x1
		result.y1 = y1
		result.is_quadratic = false
		
    result
  end
end