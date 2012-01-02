module Paleta
  class Color
    
    attr_reader :red, :green, :blue, :hue, :saturation, :lightness
    
    def initialize(red = 0, green = 0, blue = 0)
      self.red = red
      self.green = green
      self.blue = blue
    end
    
    def red=(val)
      @red = range_validator(val, 0..255)
      update_hsl
    end
    
    def green=(val)
      @green = range_validator(val, 0..255)
      update_hsl
    end
    
    def blue=(val)
      @blue = range_validator(val, 0..255)
      update_hsl
    end
    
    def lightness=(val)
      @lightness = range_validator(val, 0..100)
    end
    
    def saturation=(val)
      @saturation = range_validator(val, 0..100)
    end
    
    def hue=(val)
      @hue = range_validator(val, 0..360)
    end
    
    private
    
    def update_hsl
      r = @red / 255.0 rescue 0
      g = @green / 255.0 rescue 0
      b = @blue / 255.0 rescue 0
      
      min = [r, g, b].min
      max = [r, g, b].max
      delta = max - min
      
      @hue = 0
      @saturation = 0
      @lightness = (max + min) / 2.0
      
      if delta != 0
        @saturation = (@lightness < 0.5) ? delta / (max + min) : delta / (2.0 - max - min)
        case max
        when r; @hue = (g - b) / delta
        when g; @hue = 2 + (b - r) / delta
        when b; @hue = 4 + (r - g) / delta
        end
      end
      @hue *= 60
      @hue += 360 if @hue < 0
      @saturation *= 100
      @lightness *= 100
    end
    
    def range_validator(val, range)
      range.include?(val) ? val : raise(ArgumentError, "Component range exceeded")
    end
  end
end
