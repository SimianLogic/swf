# class Blah
#   #static props/methods
#   class << self
#   end
#   
#   def intialize
#   end
# end


class SWF
  
  #static props/methods
  class << self
    
    attr_accessor :instances  #need to init to {}
    
    def instances
      @instances ||= {}
      @instances
    end
    
  end
  
  #public variables
  attr_accessor :background_color
  attr_accessor :frame_rate
  attr_accessor :num_frames
  attr_accessor :height
  attr_accessor :symbols
  attr_accessor :width
  
  #private var symbolData:IntHash <Symbol>;
	#private var stream:SWFStream;
	#private var streamPositions:IntHash <Int>;
	#private var version:Int;
  
  def initialize(file)
    #defaults
    @symbols = {}
    
    #private values
    @symbol_data = {}
		@stream = SwfStream.new(file)
    @stream_positions = {}
    
    dimensions = @stream.read_rect
    @width = dimensions[2]
    @height = dimensions[3]
    @frame_rate = @stream.read_frame_rate
    
    @stream_positions[0] = @stream.position
    @num_frames = @stream.read_frames
    
    tag = 0
    position = @stream.position
    
    while((tag = @stream.begin_tag) != 0)
      p "READ TAG: #{Tags::tags[tag]}"
      case tag
      when Tags::SET_BACKGROUND_COLOR
        @background_color = @stream.read_rgb
      when Tags::DEFINE_SHAPE, Tags::DEFINE_SHAPE2, Tags::DEFINE_SHAPE3, Tags::DEFINE_SHAPE4, Tags::DEFINE_MORPH_SHAPE, Tags::DEFINE_MORPH_SHAPE2, Tags::DEFINE_SPRITE, Tags::DEFINE_BITS_JPEG2, Tags::DEFINE_BITS_JPEG3, Tags::DEFINE_BITS_LOSSLESS, Tags::DEFINE_BITS_LOSSLESS2, Tags::DEFINE_FONT, Tags::DEFINE_FONT2, Tags::DEFINE_FONT3, Tags::DEFINE_TEXT, Tags::DEFINE_EDIT_TEXT, Tags::DEFINE_BUTTON, Tags::DEFINE_BUTTON2
        id = @stream.read_id
        @stream_positions[id] = position
      when Tags::SYMBOL_CLASS
        read_symbol_class
      else
        p "UNIDENTIFIED TAG: #{Tags::tags[tag]} (#{tag})"
      end
      
      @stream.end_tag
      position = @stream.position
    end
  end
  
  def create_button(classname)
    id = @symbols[classname]

    if maybe_button = get_symbol(id)
      #TODO: figure out if maybe_button is a button symbol
      #TODO: create an "instance" of SimpleButton and return it      
    end
    
    return nil
  end
  
  #this one had a default value of "", but that seems like it would lead to looking up symbol 0 (assuming nil)
  #which is ok because i THINK symbol 0 is the stage
  def create_movieclip(classname="")
    id = 0
    unless classname.empty?
      return nil if @symbols[classname].nil?
      id = @symbols[classname]
    end
    
    if maybe_mc = get_symbol(id)
      #TODO: figure out if maybe_mc is a movieclip
      #TODO: create an "instance" of MovieClip and return it
    end
    
    return nil
  end

  def get_bitmap_data(classname)
    return nil if @symbols[classname].nil?

    return @symbols[classname].bitmap_data if @symbols[classname].is_a?Bitmap

    return nil
  end
  
  def get_symbol(id)
    raise "INVALID SYMBOL ID #{id}" if @stream_positions[id].nil?
    
    if @symbol_data[id].nil?
      cache_position = @stream.position
      @stream.push_tag
      
      @stream.position = @stream_positions[id]
      			
      if id == 0
        read_sprite(true)
      else
        tag = @stream.begin_tag
        p "GET TAG: #{Tags::tags[tag]}"
        case tag
        when Tags::DEFINE_SHAPE  then read_shape(1)
        when Tags::DEFINE_SHAPE2 then read_shape(2)
        when Tags::DEFINE_SHAPE3 then read_shape(3)
        when Tags::DEFINE_SHAPE4 then read_shape(4)
        
        when Tags::DEFINE_MORPH_SHAPE  then read_morph_shape(1)
        when Tags::DEFINE_MORPH_SHAPE2 then read_morph_shape(2)
          
        when Tags::DEFINE_SPRITE then read_sprite(false)
          
        when Tags::DEFINE_BUTTON  then read_button(1)
        when Tags::DEFINE_BUTTON2 then read_button(2)
          
        when Tags::DEFINE_BITS_JPEG2     then read_bitmap(false, 2)
        when Tags::DEFINE_BITS_JPEG3     then read_bitmap(false, 3)
        when Tags::DEFINE_BITS_LOSSLESS  then read_bitmap(true, 1)
        when Tags::DEFINE_BITS_LOSSLESS2 then read_bitmap(true, 2)
          
        when Tags::DEFINE_FONT  then read_font(1)
        when Tags::DEFINE_FONT2 then read_font(2)
        when Tags::DEFINE_FONT3 then read_font(3)
          
        when Tags::DEFINE_TEXT then read_text(1)
        when Tags::DEFINE_EDIT_TEXT then read_edit_text(1)
        else
          p "UNIDENTIFIED SYMBOL: #{Tags::tags[tag]} (#{tag})"
        end #end case
      end#end id==0
      
      @stream.position = cache_position
      @stream.pop_tag
    end 
    
    return @symbol_data[id]
  end
  
  def read_bitmap(lossless, version)
    id = @stream.read_id
    @symbol_data[id] = Bitmap.new(@stream, lossless, version)
  end
  
  def read_button(version)
    id = @stream.read_id
    @symbol_data[id] = Button.new(self, @stream, version)
  end
  
  def read_edit_text(version)
    id = @stream.read_id
    @symbol_data[id] = EditText.new(self, @stream, version)
  end
  
  def read_file_attributes
    flags = @stream.read_byte
    zero = @stream.read_byte
    zero = @stream.read_byte
    zero = @stream.read_byte
  end
  
  def read_font(version)
    id = @stream.read_id
    @symbol_data[id] = Font.new(@stream, version)
  end
  
  def read_morph_shape(version)
    id = @stream.read_id
    @symbol_data[id] = MorphShape.new(self, @stream, version)
  end
  
  def read_shape(version)
    id = @stream.read_id
    @symbol_data[id] = Shape.new(self, @stream, version)
  end
  
  def read_sprite(is_stage)
    id = is_stage ? 0 : @stream.read_id
    sprite = Sprite.new(self, id, @stream.read_frames)
    
    tag = 0
    while((tag = @stream.begin_tag) != 0)
      case(tag)
      when Tags::FRAME_LABEL then sprite.label_frame(@stream.read_string)
      when Tags::SHOW_FRAME then sprite.show_frame
        
      when Tags::PLACE_OBJECT  then sprite.place_object(@stream, 1)
      when Tags::PLACE_OBJECT2 then sprite.place_object(@stream, 2)
      when Tags::PLACE_OBJECT3 then sprite.place_object(@stream, 3)

      when Tags::REMOVE_OBJECT  then sprite.remove_object(@stream, 1)
      when Tags::REMOVE_OBJECT2 then sprite.remove_object(@stream, 2)
        
      when Tags::DO_ACTION
        #not implemented
      when Tags::PROTECT
        #ignored
      else
        p "unknown subTag: #{Tags::tag[tag]} (#{tag})" unless is_stage
      end #end case
      
      @stream.end_tag
    end #end while
    
    @symbol_data[id] = sprite
  end
  
  def read_text(version)
    id = @stream.read_id
    @symbol_data[id] = StaticText.new(self, @stream, version)
  end
  
  def read_symbol_class
    num_symbols = @stream.read_uint_16
    num_symbols.times do |i|
      symbol_id = @stream.read_uint_16
      classname = @stream.read_string
      @symbols[classname] = symbol_id
    end
  end
end
