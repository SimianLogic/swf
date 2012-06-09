class DisplayAttributes
  
  attr_accessor :color_transform, :filters, :frame, :matrix, :name, :ratio, :symbol_id

	def apply(object)
    object.transform.matrix = matrix.clone unless @matrix.nil?
    object.transform.color_transform = color_transform unless @color_transform.nil?
    object.name = @name
    object.filters = filters if object.filters != filters
    
    object.set_ratio(ratio) if(ratio != nil && object.is_a?MorphObject)
      
    false
  end
	
	def clone
	  copy = DisplayAttributes.new
	  copy.frame = @frame
	  copy.matrix = @matrix
	  copy.color_transform = @color_transform
	  copy.ratio = @ratio
	  copy.name = @name
	  copy.symbol_id = @symbol_id
	  copy
  end
end