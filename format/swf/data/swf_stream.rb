require 'zlib'
require 'stringio'

class StringIO

  def read_unsigned_byte
    read(1).unpack("C").first
  end
  
  def read_unsigned_short
    read(2).unpack("S").first
  end
  
  def read_unsigned_int
    read(4).unpack("L").first
  end
  
  def read_uint_16
    read(2).unpack("S").first
  end
  
  def read_short
    read(2).unpack("s").first
  end
  
  def read_int
    read(4).unpack("l").first
  end
end

class SwfStream
  #static props/methods
  class << self
    
  end
  
  attr_accessor :bit_position
  attr_accessor :byte_buffer
  attr_accessor :stream
  attr_accessor :tag_read
  attr_accessor :tag_size
  attr_accessor :version
  
  def initialize(swf_file)
    @push_tag_read = 0
    @push_tag_size = 0
    
    swf_file.seek(0)
    
    signature = swf_file.read(3)
    raise "Invalid Signature" unless ["FWS","CWS"].include?signature

    @version = swf_file.readbyte
    
    length = swf_file.read(4).unpack('l')

    #now read the rest...
    raw_stream = swf_file.read
    if(signature == "CWS")
      #read the rest
      raw_stream = Zlib::Inflate.inflate raw_stream
    end
    @stream = StringIO.new(raw_stream)
    
    #stream.endian = Endian.LITTLE_ENDIAN
    @bit_position = 0
    @byte_buffer = 0
    @tag_read = 0
  end
  
  def position=(p)
    @stream.seek p
  end
  
  def position
    @stream.pos
  end
  
  def align_bits
    @bit_position = 0
  end
  
  def close
    stream = nil
  end
  
  def getBytesLeft
    tag_size - tag_read
  end

  def begin_tag
    data = @stream.read_unsigned_short
    tag = data >> 6
    length = data & 0x3f
    
    return 0 if tag >= Tags::LAST
    
    length = @stream.read_unsigned_int if length == 0x3f
    
    @tag_size = length
    @tag_read = 0
    return tag
  end
  
  def end_tag
    read = @tag_read
    size = @tag_size
    if(read > size)
      raise "Tag read overflow"
    end
    
    while(read < size)
      @stream.read_unsigned_byte
      read += 1
    end
  end
  
  def pop_tag
    @tag_read = @push_tag_size
    @tag_size = @push_tag_size
  end
  
  def push_tag
    @push_tag_read = @tag_read
    @push_tag_size = @tag_size
  end
  
  def read_byte
    @tag_read += 1
    @stream.read_unsigned_byte
  end
  
  def read_align
    options = {
        0 => "LEFT",
        1 => "RIGHT",
        2 => "CENTER",
        3 => "JUSTIFY"
      }
      
    options[read_byte] || "LEFT"
  end
  
  def read_array_size(extended=false)
    @tag_read += 1
    result = @stream.read_unsigned_byte
    
    if(extended && result == 0xff)
      @tag_read += 2
      result = @stream.read_unsigned_short
    end
    
    result
  end
  
  def read_bool
	  read_bits(1) == 1
  end
  
  def read_bits(length, isSigned=false)
	  sign_bit = length - 1
	  result = 0
	  bits_left = length
	  
	  while (bits_left != 0)
	    if @bit_position == 0
	      @byte_buffer = @stream.read_unsigned_byte
	      @tag_read += 1
	      @bit_position = 8
      end
      
      while(@bit_position > 0 && bits_left > 0)
        result = (result << 1) | ((@byte_buffer >> 7) & 1)
        @bit_position -= 1
        bits_left -= 1
        @byte_buffer = @byte_buffer << 1
      end
    end
    
    if isSigned
      mask = (1 << sign_bit)
      if((result & mask) != 0)
        result -= (1 << length)
      end
    end
    
    result
  end
  
  def read_bytes(length)
    @tag_read += length
    StringIO.new(@stream.read(length))
  end
  
  def read_cap_style
    cap = read_bits(2)
    
    return "ROUND" if cap == 0
    return "NONE" if cap == 1
    return "SQUARE" if cap == 2
    
    return "ROUND"
  end
  
  def read_color_transform(with_alpha=false)
    align_bits    
    #result = new ColorTransform
    
    has_offset = read_bool
    has_multiplier = read_bool
    
    length = read_bits(4)
    
    if(!hasOffset && !hasMultiplier)
      align_bits
      return nil
    end
    
    if has_multiplier
      red_multiplier = read_bits(length, true) / 256.0
      green_multiplier = read_bits(length, true) / 256.0
      blue_multiplier = read_bits(length, true) / 256.0
      alpha_multiplier = read_bits(length, true) / 256.0 if with_alpha
    end #end has_multiplier
    
    if has_offset
      red_offset = read_bits(length, true)
      green_offset = read_bits(length, true)
      blue_offset = read_bits(length, true)
      alpha_offset = read_bits(length, true) if with_alpha
    end
  
    align_bits
    p "TODO: RETURN COLOR TRANSFORM"
    nil
  end
  
  def read_depth
    @tag_read += 2
    @stream.read_unsigned_short
  end
  
  def read_fixed
    align_bits
    frac = read_uint_16 / 65536.0
    read_uint_16 + frac
  end
  
  def read_fixed_8
    align_bits
    frac = read_byte / 256.0
    read_byte + fac
  end
  
  def read_fixed_bits(length)
    read_bits(length, true) / 65536.0
  end
  
  def read_flash_bytes(length)
    @tag_read += length
    StringIO.new(@stream.read_bytes(length))
  end
  
  def read_float
    @tag_read += 4
    @stream.read_int
  end
  
  def read_frame_rate
    @stream.read_unsigned_short / 256.0
  end
  
  def read_frames
    @stream.read_unsigned_short
  end
  
  def read_id
    @tag_read += 2
    @stream.read_unsigned_short
  end
  
  def read_int
    @tag_read += 4
    @stream.read_int
  end
  
  def read_interpolation_method
    im = read_bits(2)
    return "RGB" if im == 0
    return "LINEAR_RGB" if im == 1
    
    "RGB"
  end
  
  def read_join_style
    js = read_bits(2)
    
    return "ROUND" if js == 0
    return "BEVEL" if js == 1
    return "MITER" if js == 2
    
    "ROUND"
  end
  
  def read_matrix
    #TODO: MATRIX
    #result = Matrix.new
    align_bits
    
    has_scale = read_bool
    scale_bits = has_scale ? read_bits(5) : 0
    
    a = has_scale ? read_fixed_bits(scale_bits) : 1.0
    d = has_scale ? read_fixed_bits(scale_bits) : 1.0
    
    has_rotate = read_bool
    rotate_bits = has_rotate ? read_bits(5) : 0
    
    b = has_rotate ? read_fixed_bits(rotate_bits) : 0.0
    c = has_rotate ? read_fixed_bits(rotate_bits) : 0.0
    
    trans_bits = read_bits(5)
    tx = read_twips(trans_bits)
    ty = read_twips(trans_bits)
    
    p "TODO: RETURN A MATRIX"
    return nil
  end
  
  def read_pascal_string
    length = read_byte
    result = ""
    
    length.times do 
      code = read_byte
      result << code.chr if code > 0
    end
    
    result
  end

  def read_rect
    #TODO: RECTANGLE
    align_bits
    bits = read_bits(5)
    x0 = read_twips(bits)
    x1 = read_twips(bits)
    y0 = read_twips(bits)
    y1 = read_twips(bits)
    
    p "TODO: return rectangle"
    return [x0,y0,x1-x0,y1-y0]
  end
  
  def read_rgb
    @tag_read += 3
    r = @stream.read_unsigned_byte
    g = @stream.read_unsigned_byte
    b = @stream.read_unsigned_byte
    
    (r << 16) | (g << 8) | b
  end
  
  def read_scale_mode
    sm = read_bits(2)
    
    return "NORMAL" if sm == 0
    return "HORIZONTAL" if sm == 1
    return "VERTICAL" if sm == 2
    return "NONE" if sm == 3
    
    "NORMAL"
  end
  
  def read_sint_16
    @tag_read += 2
    @stream.read_short
  end
  
  def read_stwips
    read_sint_16 * 0.05
  end
  
  def read_spread_method
    sm = read_bits(2)
    
    return "PAD" if sm == 0
    return "REFLECT" if sm == 1
    return "REPEAT" if sm == 2
    return "PAD" if sm == 3
    
    "REPEAT"
  end
  
  def hello
    p "HELLO"
  end
  
  def read_string
    result = ""
    while(true)
      code = read_byte
      return result if code == 0
      
      result << code.chr
    end
    
    result
  end
  
  def read_twips(length)
    read_bits(length, true) * 0.05
  end
  
  def read_uint_16
    @tag_read += 2
    @stream.read_unsigned_short
  end
  
  def read_utwips
    read_uint_16 * 0.05
  end
end