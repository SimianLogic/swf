
class MovieClip #< Sprite
	
	attr_accessor :current_frame, :current_frame_label, :current_label, :current_labels, :enabled,
	              :frames_loaded, :total_frames, :track_as_menu
	              
  
  def initialize(data=nil) #data is a Sprite
    #private vars
    @active_objects = []
    @frames = []
    @swf = nil
    
    @object_pool = {}
    
    @enabled = true
    @playing = false
    
    @current_frame_label = nil
    @current_label = nil
    @current_labels = []
    
    unless data.nil?
      @total_frames = data.frame_count
      @current_frame = total_frames
      @frames_loaded = total_frames
      
      @swf = data.swf
      @frames = data.frames
      
      data.frame_labels.each do |k,v|
        frame_label = FrameLabel.new(v, k)
        current_labels << frame_label
      end
		
			goto_and_play(1)
			
		else #no swf, dynamic mc
			p "NO SWF PROVIDED"
			@current_frame = 1
			@total_frames = 1
			@frames_loaded = 1
		end

	end
	
	#more DRY
	def goto(frame, scene=nil)
	  
	  if frame.is_a?String
	    @current_labels.each do |frame_label|
	      if frame_label.name == frame
	        @current_frame = frame_label.frame
	        break
        end
      end
    else
      @current_frame = frame
		end
		update_objects
  end
  
	#appears scenes aren't implemented
	def goto_and_play(frame, scene=nil)
	  goto(frame)
    play		
	end
  
  def goto_and_stop(frame, scene=nil)
    goto(frame)
    stop
  end
	
	def next_frame
	  nf = @current_frame + 1
	  nf = @total_frames if nf > @total_frames
	    
	  goto_and_stop(nf)
  end
	
	#def next_scene
	#unimplemented
	
	def play
	  if @total_frames > 1
	    playing = true
	    
      p "TODO: ENTER FRAME EVENT"
			#removeEventListener (Event.ENTER_FRAME, this_onEnterFrame);
			#addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
		else
			stop
	  end	
	end
	
	def prev_frame
	  previous = @current_frame - 1
	  previous = 1 if(previous < 1)
	
	  goto_and_stop(previous)
  end

	def stop
	  playing = false
	  p "TODO: REMOVE ENTER FRAME EVENT"
		#removeEventListener (Event.ENTER_FRAME, this_onEnterFrame);
  end

	def update_objects
    unless @frames.nil?
      frame = @frames[@current_frame]
      depth_changed = false
      waiting_loader = false
      
      unless frame.nil?
        frame_objects = frame.copy_object_set
        new_active_objects = []
        
        @active_objects.each do |active_object|
          depth_slot = frame_objects[active_object.depth]
          if(depth_slot.nil? || depth_slot.symbol_id != active_object.symbol_id || active_object.waiting_loader)

					  #add object to pool -- if it's complete
						unless active_object.waiting_loader
						  pool = @object_pool[active_object.symbol_id]
						  						
              if pool.nil? #cache miss
							  pool = []
							  @object_pool[active_object.symbol_id] = pool
							end
							
							pool << active_object.object
							
						end
						
						#todo: disconnect event handlers?
            remove_child(active_object.object)
						
					else
						
						#remove from our "todo" list
						frame_objects.delete active_object.depth
            
            active_object.index = depth_slot.find_closest_frame(active_object.index, @current_frame)
            attributes = depth_slot.attributes[active_object.index]
            
            attributes.apply(active_object.object)
            
            new_active_objects << active_object
						
						
				  end
				  
				end
				
				#Now add missing characters in unfilled depth slots
				frame_objects.each do |depth, slot|
        
          display_object = nil
          
          pool = @object_pool[slot.symbol_id]

          if(pool && pool.length > 0)
            display_object = pool.pop
            #in the hx file, we check if it's a sprite, cast it to MC, and then call play
            #in ruby, I'm pretty sure we'd just check to see if it's an MC straight up
            #### the case spriteSymbol might be more akin to is this a MovieClipDefinition, though.....
            display_object.goto_and_play(1) if slot.symbol.is_a?MovieClip

          else
            
            if slot.symbol.is_a?Sprite
              mc = MovieClip.new(slot.symbol)
              display_object = mc
            elsif slot.symbol.is_a?Shape
              s = Shape.new
              s.cache_as_bitmap = true
              #commented out in original... but we need to draw at some point
              #slot.symbol.Render(new nme.display.DebugGfx());
              
              #this part makes sense... using the original Shape as the definition. 
              #create a new shape and draw it's data into this new shape.
              waiting_loader = slot.symbol.render(s.graphics)
              display_object = s
						
            
						elsif slot.symbol.is_a?MorphObject
						  morph = MorphObject.new(slot.symbol)
							#commented out in original...looks like not implemented
							#morph_data.Render(new nme.display.DebugGfx(),0.5);
						  display_object = morph
						
						elsif slot.symbol.is_a?StaticText
						  s = Shape.new
						  s.cache_as_bitmap = true #temp fix
						  slot.symbol.render(s.graphics)
						  display_object = s	
						
						elsif slot.symbol.is_a?TextField
						  
						  t = TextField.new
						  slot.symbol.apply(t)
						  display_object = t	
						
						elsif slot.symbol.is_a?Bitmap
						  raise "Adding bitmap?"
					  elsif slot.symbol.is_a?Font
					    raise "Adding font?"
				    elsif slot.symbol.is_a?SimpleButton
				      b = SimpleButton.new
				      slot.symbol.apply(b)
				      display_object = b
			      end
					end #end of pool/length if statement
					
					#took out all the have_swf_depth defines, will add it later if i think i need it					
					added = false

					#todo: binary converge?
					num_children.each do |cid|
					  child_depth = -1
					  sought = get_child_at(cid)
					  
					  new_active_objects.each do |child|
					    if child.object == sought
					      child_depth = child.depth
					      break
				      end
			      end
					  
					  if child_depth > depth
					    add_child_at(display_object, cid)
					    added = true
				    end
						
						
					end
					
					add_child(display_object) unless added
					  
					idx = slot.find_closest_frame(0, @current_frame)
					slot.attributes[idx].apply(display_object)
					
					act = { "object" => display_object,
					        "depth" => depth,
					        "index" => idx,
					        "symbol_id" => slot.symbol_id,
					        "waiting_loader" => waiting_loader
					}
					
					new_active_objects << act
					depth_changed = true
					
				end #end of frame_objects loop
				
				active_objects = new_active_objects
				@current_frame_label = nil
				
				@current_labels.each do |frame_label|
				  if frame_label.frame < frame.frame
				    @current_label = frame_label.name
          elsif frame_label.frame == frame.frame
            @current_frame_label = frame_label.name
            @current_label = @current_frame_label
            break
          else
            break
          end
				end
				
      end
    end
  end
	
	
	def this_on_enter_frame(event)
	  if playing
	    @current_frame += 1
	    @current_frame = 1 if @current_frame > @total_frames
	    update_objects
    end
  end
	
	
end

class ActiveObject
  attr_accessor :object, :depth, :symbol_id, :index, :waiting_loader
end
