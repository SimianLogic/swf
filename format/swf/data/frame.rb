class Frame
  attr_accessor :frame
  
  #static props/methods
  class << self
  end
  
  def initialize(previous_frame=nil)
    @objects = {}
    #init our objects hash with the pre-existing positions
    if previous_frame.nil?
      @frame = 1
    else
      @frame = previous_frame.frame + 1
      previous_frame.objects.each do |depth, object|
        @objects[depth] = object
      end
    end
  end
  
  #just to keep method parity...
  def copyObjectSet
    @objects.clone
  end
  
  def move(depth, matrix, color_transform, ratio)
    object = @objects[depth]
    raise "Depth has no object!" if object.nil?
    
    object.move(frame, matrix, colorTransform, ratio)
  end
  
  def place(symbol_id, symbol, depth, matrix, color_transform, ratio, name, filters)
    previous_object = @objects[depth]
    unless previous_object.nil?
      if matrix.nil?
        matrix = previous_object.attributes[0].matrix
      end
    end
    
    attributes = DisplayAttributes.new
    attributes.frame = frame
    attributes.matrix = matrix
    attributes.color_transform = color_transform
    attributes.ratio = ratio
    attributes.name = name.nil? ? "" : name
    attributes.filters = filters
    attributes.symbol_id = symbol_id
    
    object = DepthSlot.new(symbol_id, symbol, attributes)
    @objects[depth] = object
  end
  
  def remove(depth)
    @objects.delete depth
  end
end