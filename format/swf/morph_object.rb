

class MorphObject #extends Sprite

  def initialize(data)
    #super
    @data = data
  end
	
	def set_ratio(ratio)
	  p "TODO: graphics & clear"
	  #graphics.clear
	  
    f = ratio / 65536.0
    
    #return @data.render(graphics, f)
	end
end