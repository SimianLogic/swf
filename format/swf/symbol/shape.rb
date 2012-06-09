class Shape
 
  FT_SOLID      = 0x00
  FT_LINEAR     = 0x10
  FT_RADIAL     = 0x12
  FT_RADIAL_F   = 0x13

  FT_BITMAP_REPEAT_SMOOTH   = 0x40
  FT_BITMAP_CLIPPED_SMOOTH  = 0x41
  FT_BITMAP_REPEAT          = 0x42
  FT_BITMAP_CLIPPED         = 0x43
  
  attr_accessor :waiting_loader
     
  def initialize(swf, stream, version)
    @commands = [] #RenderCommands
    @edge_bounds = Rectangle.new
    @has_non_scaled = false
    @has_scaled = false
    @swf = swf

    
    stream.align_bits
    @bounds = stream.read_rect
    @wating_loader = false
    
    if version == 4
      stream.align_bits
      edge_bounds = stream.read_rect
      stream.align_bits
      stream.read_bits(6)
      
      has_non_scaled = stream.read_bool
      has_scaled = stream.read_bool
    else
      edge_bounds = bounds.clone
      has_scaled = true
      has_non_scaled = true
    end
    
    @fill_styles = read_fill_styles(stream, version)
    line_styles = read_line_styles(stream, version)
        
    stream.align_bits
    
    fill_bits = stream.read_bits(4)
    line_bits = stream.read_bits(4)
    
    pen_x = 0.0
    pen_y = 0.0
    
    current_fill_0 = -1
    current_fill_1 = -1
    current_line = -1
    
    edges = []
    fills = []
    
		while true
			edge = stream.read_bool
			if(!edge)
				new_styles = stream.read_bool
				new_line_style = stream.read_bool
        new_fill_style_1 = stream.read_bool
        new_fill_style_0 = stream.read_bool
        move_to = stream.read_bool
        
        #End-of-shape - Done!
        if(!move_to and !new_styles and !new_line_style && !new_fill_style_1 && !new_fill_style_0)
          break
        end
				
				#style changed record
				if move_to
				  bits = stream.read_bits(5)
				  px = stream.read_twips(bits)
				  py = stream.read_twips(bits)
				  
				  #will probably have to change how this works, but for now the idea
				  #is that the object with the move command will be passed in...
				  edges << Proc.new {|graphics| graphics.move_to(px, py) }
				  
				  pen_x = px
				  pen_y = py
			  end
			  
			  if new_fill_style_0
			    current_fill_0 = stream.read_bits(fill_bits)
		    end
			  
				if new_fill_style_1
				  current_fill_1 = stream.read_bits(fill_bits)
			  end
				
				if new_line_style
				  line_style = stream.read_bits(line_bits)
          
          raise "NULL LINE STYLE: #{line_bits}" if line_style.nil?
				  raise "Invalid line style: #{line_style} / #{line_styles.length} (#{line_bits})" if(line_style >= line_styles.length)
				  
				  function = line_styles[line_style]
				  edges << function
				  current_line = line_style
			  end
				
				#Hmmm - do this, or just flush fills?
				if new_styles
				  flush_commands(edges, fills)
				  edges = [] if edges.length > 0
				  fills = [] if fills.length > 0
				  
				  stream.align_bits
				  
				  @fill_styles = read_fill_styles(stream, version)
				  line_styles = read_line_styles(stream, version)
				  
				  fill_bits = stream.read_bits(4)
				  line_bits = stream.read_bits(4)
				  
				  current_line = -1
				  current_fill_0 = -1
				  current_fill_1 = -1
				end
      else #matches "if !edge", i.e. now we have an edge!
        
        if stream.read_bool
          #straight
          px = pen_x
          py = pen_y
          
          delta_bits = stream.read_bits(4) + 2
          if stream.read_bool
            px += stream.read_twips(delta_bits)
            py += stream.read_twips(delta_bits)
          elsif stream.read_bool
            py += stream.read_twips(delta_bits)
          else
            px += stream.read_twips(delta_bits)
          end

          if current_line > 0
            edges << Proc.new{ |graphics| graphics.line_to(px, py) }
          else
        		edges << Proc.new{ |graphics| graphics.move_to(px, py) }
      		end
      		
      		if current_fill_0 > 0
      		  fills << ShapeEdge::line(current_fill_0, pen_x, pen_y, px, py)
    		  end
    		  
    		  if current_fill_1 > 0
    		    fills << ShapeEdge::line(current_fill_1, px, py, pen_x, pen_y)
					end
          
          pen_x = px
          pen_y = py
					
        else #our stream.read_bool
					
					#not a straightedge -- let's curve!
					
					delta_bits = stream.read_bits(4) + 2
					cx = pen_x + stream.read_twips(delta_bits)
					cy = pen_y + stream.read_twips(delta_bits)
					px = cx + stream.read_twips(delta_bits)
					py = cy + stream.read_twips(delta_bits)
					
					#Can't push "pen_x/y" in closure because it uses a reference
					#to the member variable, not a copy of the current value.
					
					if current_line > 0
					  edges << Proc.new{ |graphics| graphics.curve_to(cx, cy, px, py) }
				  end
				  
				  if current_fill_0 > 0
				    fills << ShapeEdge::curve(current_fill_0, pen_x, pen_y, cx, cy, px, py)
			    end

          if current_fill_1 > 0
            fills << ShapeEdge::curve(current_fill_1, px, py, cx, cy, pen_x, pen_y)
          end
          
					pen_x = px
					pen_y = py
				end
			end		
		end
		
		flush_commands(edges, fills)
		
		@swf = nil
	end
	
	#THIS IS CRASHING (first is nil) -- I SUSPECT IT WAS THE WONKY fills[--fills_left]
	#CHECK TO SEE IF THIS RETURNS PRE OR POST VALUE IN HAXE
	def flush_commands(edges, fills)
	  fills_left = fills.length
	  
	  while fills_left > 0
	    first = fills[0]
	    fills_left -= 1
	    fills[0] = fills[fills_left]
	    
	    raise "Invalid Fill Style" if first.fill_style >= @fill_styles.length
	    
      @commands << @fill_styles[first.fill_style]
			
      mx = first.x0
      my = first.y0
      
      @commands << Proc.new{ |graphics| graphics.move_to(mx,my) }
			
			@commands << first.as_command
			
      prev = first
      looping = false
			
			while(!looping)
			  found = false
			  fills_left.times do |i|
			    if prev.connects(fills[i])
			      prev = fills[i]
			      fills_left -= 1
			      fills[i] = fills[fills_left]
			      
			      @commands << prev.as_command
			      
			      found = true			      
			      looping = true if prev.connects(first)
			      break
					end	
				end	

        if !found
          p "Remaining: "
          fills.map &:dump			  
				  raise "Daingling fill: #{prev.x1},#{prev.y1} #{prev.fill_style}"
					break
				end	
			end	
    end #end while
    
    @commands << Proc.new{ |graphics| graphics.end_fill } if fills.length > 0
      
		
		@commands = @commands + edges
		
		@commands << Proc.new{ |graphics| graphics.line_style } if edges.length > 0
		
	end
	
	def read_fill_styles(stream, version)
	  result = []
	  
	  #special null fill-style
	  result << Proc.new{ |graphics| graphics.end_fill }
	  
	  count = stream.read_array_size(true)
	  
    count.times do |i|
      fill = stream.read_byte
      if fill == FT_SOLID
        rgb = stream.read_rgb
        alpha = version >= 3 ? (stream.read_byte / 255.0) : 1.0
        
        result << Proc.new{ |graphics| graphics.begin_fill(rgb, alpha)}
      elsif (fill == FT_LINEAR || fill == FT_RADIAL || fill == FT_RADIAL_F)
        #GRADIENT
        matrix = stream.read_matrix
        
        stream.align_bits
        
        spread = stream.read_spread_method
        interp = stream.read_interpolation_method
        num_colors = stream.read_bits(4)
        
        colors = []
        alphas = []
        ratios = []
        
        num_colors.times do
          ratios << stream.read_byte
          colors << stream.read_rgb
          alphas << (version >= 3 ? stream.read_byte/255.0 : 1.0)
        end
				
				focus = (fill == FT_RADIAL_F ? stream.read_byte/255.0 : 0)
				type = (fill == FT_LINEAR ? GradientType::LINEAR : GradientType::RADIAL)
				
        result << Proc.new{ |graphics| graphics.begin_gradient_fill(type, colors, alphas, ratios, matrix, spread, interp, focus)}
			
			elsif (fill == FT_BITMAP_REPEAT_SMOOTH || fill == FT_BITMAP_CLIPPED_SMOOTH || fill = FT_BITMAP_REPEAT || fill == FT_BITMAP_CLIPPED)

			  #Bitmap
				stream.align_bits
				
        id = stream.read_id
        matrix = stream.read_matrix
        
        p "TODO: MATRICES?  with a/b/c/d props"
				matrix.a = matrix.a * 0.05;
				matrix.b = matrix.b * 0.05;
				matrix.c = matrix.c * 0.05;
				matrix.d = matrix.d * 0.05;
				
        stream.align_bits
        
        repeat = (fill == FT_BITMAP_REPEAT || fill == FT_BITMAP_REPEAT_SMOOTH)
				smooth = (fill == FT_BITMAP_REPEAT_SMOOTH || fill == FT_BITMAP_CLIPPED_SMOOTH)
        
				bitmap = null
				if id != 0xffff
          test = swf.get_symbol(id)
          p "This bit is wonky... what is bitmap_symbol?"
          bitmap = test.bitmap_data if test.is_a?Bitmap
        end
        
        if bitmap.nil?
          #may take some time for the bitmap to load...
          s = swf
          me = self
          
          result << Proc.new do |graphics| 
            if bitmap.nil?
              if id != 0xffff
                test = s.get_symbol(id)
                bitmap = test.bitmap_data if test.is_a?Bitmap
              end
              
              if bitmap.nil?
                me.waiting_loader = true
                graphics.end_fill
                return
              else
                me = nil
              end
            end
            
            graphics.begin_bitmap_fill(bitmap, matrix, repeat, smooth)
          end
        else
          result << Proc.new{ |graphics| graphics.begin_bitmap_fill(bitmap, matrix, repeat, smooth)}  
        end
					
      else
        raise "Unknown fill style: 0x#{StringTools::hex(fil)}"
				
			end
		end
		
		result
	end
	
	
	def read_line_styles(stream, version)
	  result = []
	  
	  result << Proc.new{ |graphics| graphics.line_style }
	  
	  count = stream.read_array_size(true)

	  count.times do
	    #linestyle 2
	    if version >= 4
	      stream.align_bits
				
				width = stream.read_depth * 0.05
				start_caps = stream.read_caps_style
				joints = stream.read_join_style
				has_fill = stream.read_bool
				scale = stream.read_scale_mode
				pixel_hint = stream.read_bool
				reserved = stream.read_bits(5)
				no_close = stream.read_bool
			  end_caps = stream.read_caps_style
			  miter = (joints == JointStyle::MITER ? stream.read_depth/256.0 : 1.0)
			  color = (has_fill ? 0 : stream.read_rgb)
			  alpha = (has_fill ? 1.0 : stream.read_byte / 255.0)
				
				if has_fill
				  fill = stream.read_byte
				  
				  #Gradient
				  if((fill & 0x10) != 0)
				    matrix = stream.read_matrix
				    stream.align_bits
				    
				    spread = stream.read_spread_method
				    interp = stream.read_interpolation_method
				    num_colors = stream.read_bits(4)
				    
				    colors = []
				    alphas = []
				    ratios = []
				    
				    num_colors.times do
				      ratios << stream.read_byte
				      colors << stream.read_rgb
				      alphas << stream.read_byte / 255.0
			      end
						
						focus = (fill == FT_RADIAL_F ? stream.read_byte / 255.0 : 0)
						type = (fill = FT_LINEAR ? GradientType::LINEAR : GradientType::RADIAL)
						
						result << Proc.new do |graphics|
						  graphics.line_style(width, 0, 1, pixel_hint, scale, start_caps, joints, miter)
						  graphics.line_gradient_style(type, colors, alphas, ratios, matrix, spread, interp, focus)
					  end
						
					else
					  raise "Unknown fillstyle"
				  end

				else #no fill
          
          result << Proc.new{ |graphics| graphics.line_style(width, color, alpha, pixel_hint, scale, start_caps, joints, miter)}
					
					
				end
				
			else #version < 4
			  
			  stream.align_bits
			  width = stream.read_depth * 0.05
			  rgb = stream.read_rgb
			  alpha = (version >= 3 ? stream.read_bytes/255.0 : 1.0)
				
				result << Proc.new{ |graphics| graphics.line_style(width, rgb, alpha) }
				
			end
			
		end
		
    result
	end
	
	def render(graphics)
	  @waiting_loader = false

    #@commands is an array of procs
	  @commands.each do |command|
	    command.call(graphics)
    end
    
    return @waiting_loader
  end
	
end


