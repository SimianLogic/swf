class Sprite

  attr_accessor :frame_count
  attr_accessor :frame_labels
  attr_accessor :frames
  attr_accessor :swf
  
  #   private var blendMode:BlendMode;
  #   private var cacheAsBitmap:Bool;
  #   private var className:String;
  #   private var frame:Frame;
  #   private var name:String;
  
  def initialize(swf, id, frame_count)
    #initialize/assign defaults
    @swf = swf
    @frame_count = frame_count
    @frame_labels = {}
    @frames = [nil] #frame 0 is empty
    
    #private vars
    @blend_mode = nil
    @cache_as_bitmap = false
    @classname = nil
    @frame = Frame.new
    @name = "Sprite#{id}"    
  end
  
  def label_frame(name)
    @frame_labels[name] = @frame.frame
  end
  
  def place_object(stream, version)
    if version == 1
      symbol_id = stream.read_id
      symbol = swf.get_symbol(symbol_id)
      depth = stream.read_depth
      matrix = stream.read_matrix
      color_transform = nil
      
      color_transform = stream.read_color_transform(false) if stream.get_bytes_left > 0
        
      frame.place(symbol_id, symbol, depth, matrix, color_transform, nil, nil, nil)
      
    elsif (version == 2 || version == 3)
      stream.align_bits
      
      has_clip_action = stream.read_bool
      has_clip_depth = stream.read_bool
      has_name = stream.read_bool
      has_ratio = stream.read_bool
      has_color_transform = stream.read_bool
      has_matrix = stream.read_bool
      has_symbol = stream.read_bool
      move = stream.read_bool
      
      has_image = false
      has_classname = false
      has_cache_as_bitmap = false
      has_blend_mode = false
      has_filter_list = false
      
      if(version == 3)
        stream.read_bool
        stream.read_bool
        stream.rad_bool
        
        has_image = stream.read_bool
        has_classname = stream.read_bool
        has_cache_as_bitmap = stream.read_bool
        has_blend_mode = stream.read_bool
        has_filter_list = stream.read_bool
      end
      
      if has_classname
        @classname = stream.read_string
      end
      
      symbol_id = has_symbol ? stream.read_id : 0
      matrix = has_matrix ? stream.read_matrix : nil
      color_transform = has_color_transform ? stream.read_color_transform(true) : nil
      ratio = has_ratio ? stream.read_uint_16 : nil
      name = nil
      
      if(has_name or (has_image && has_symbol))
        name = stream.read_string
      end
      
      clip_depth = has_clip_depth ? stream.read_depth : 0
      filters = has_filter_list ? Filters::read_filters(stream) : nil
      if has_blend_mode
        next_byte = stream.read_byte
        @blend_mode = case(next_byte)
        when 2 then BlendMode::LAYER
        when 3 then BlendMode::MULTIPLY
        when 4 then BlendMode::SCREEN
        when 5 then BlendMode::LIGHTEN
        when 6 then BlendMode::DARKEN
        when 7 then BlendMode::DIFFERENCE
        when 8 then BlendMode::ADD
        when 9 then BlendMode::SUBTRACT
        when 10 then BlendMode::INVERT
        when 11 then BlendMode::ALPHA
        when 12 then BlendMode::ERASE
        when 13 then BlendMode::OVERLAY
        when 14 then BlendMode::HARDLIGHT
        else
          BlendMode::NORMAL
        end
      end
      
      @cache_as_bitmap =  (stream.read_byte > 0) if has_blend_mode
      
      if has_clip_action
        reserved = stream.read_id
        action_flags = stream.read_id
        raise "clip action not implemented"
      end
      
      if move
        if has_symbol
          frame.place(symbol_id, swf.get_symbol(symbol_id), depth, matrix, color_transform, ratio, name, filters)
        else
          frame.move(depth, matrix, color_transform, ratio)
        end
      else
        frame.place(symbol_id, swf.get_symbol(symbol_id), depth, matrix, color_transform, ratio, name, filters)
      end
          
    else
      raise "Place object not implemented: #{version}"  
    end
  end
  
  def remove_object(stream, version)
    stream.read_id if version == 1
    
    depth = stream.read_depth
    frame.remvoe(depth)
  end
  
  def show_frame
    frames << frame
    frame = Frame.new(frame)
  end
  
end
