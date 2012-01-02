module Paleta
  class Color
    
    attr_reader :red, :green, :blue
    
    def initialize(red = 0, green = 0, blue = 0)
      self.red = red
      self.green = green
      self.blue = blue
    end
    
    def red=(val)
      @red = range_validator(val)
    end
    
    def green=(val)
      @green = range_validator(val)
    end
    
    def blue=(val)
      @blue = range_validator(val)
    end
    
    private
    
    def range_validator(val)
      val >= 0 && val <= 255 ? val : raise(ArgumentError, "Component range exceeded")
    end
  end
end
