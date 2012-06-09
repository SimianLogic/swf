class DepthSlot
	
	attr_accessor :attributes, :symbol, :symbol_id

	def initialize(symbol_id, symbol, attributes)
	  @symbol_id = symbol_id
	  @symbol = symbol

	  @attributes = [attributes]
	  
	  @cache_attributes = attributes
  end
	
	def find_closest_frame(hint_frame, frame)
	  last = hint_frame
	  if(last >= attributes.length)
	    last = 0
    elsif(last > 0)
      last = 0 if(attributes.last.frame > frame)
		end

    #don't include attributes.length
    (last...attributes.length).each do |i|
      return last if attributes[i].frame > frame
      last = i
    end
		
		last
	end
	
	
	def move(frame, matrix, color_transform, ratio)
	  cache_attributes = cache_attributes.clone
	  cache_attributes.frame = frame
		
		cache_attributes.matrix = matrix unless matrix.nil?
		cache_attributes.color_transform = color_transform unless color_transform.nil?
		cache_attributes.ratio = ratio unless ratio.nil?
		
		attributes << cache_attributes
	end

end