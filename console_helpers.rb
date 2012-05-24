module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

#this reloads your code, but you're going to have to quit
#and run again if you want to refresh your constants
def reload
  suppress_warnings do 
    Dir['./**/*.rb'].each do |f| 
      load f
    end
  end
  nil
end