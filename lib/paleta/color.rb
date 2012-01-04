module Paleta
  class Color
    include Math
    
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
      update_rgb
    end
    
    def saturation=(val)
      @saturation = range_validator(val, 0..100)
      update_rgb
    end
    
    def hue=(val)
      @hue = range_validator(val, 0..360)
      update_rgb
    end
    
    def lighten!(percent = 5)
      @lightness += percent
      @lightness = 100 if @lightness > 100
      update_rgb
    end
    
    def darken!(percent = 5)
      @lightness -= percent
      @lightness = 0 if @lightness < 0
      update_rgb
    end
    
    def similarity(color)
      sqrt(((@red - color.red) * (@red - color.red)) + ((@green - color.green) * (@green - color.green)) + ((@blue - color.blue) * (@blue - color.blue))) / 441.6729559300637
    end
    
    private
    
    def update_hsl
      r = @red / 255.0 rescue 0
      g = @green / 255.0 rescue 0
      b = @blue / 255.0 rescue 0
      
      min = [r, g, b].min
      max = [r, g, b].max
      delta = max - min
      
      h = s = 0
      l = (max + min) / 2.0
      
      if delta != 0
        s = (l < 0.5) ? delta / (max + min) : delta / (2.0 - max - min)
        case max
        when r; h = (g - b) / delta
        when g; h = 2 + (b - r) / delta
        when b; h = 4 + (r - g) / delta
        end
      end
      @hue = h * 60
      @hue += 360 if @hue < 0
      @saturation = s * 100
      @lightness = l * 100
    end
    
    def update_rgb
      
      h = @hue / 360.0
      s = @saturation / 100.0
      l = @lightness / 100.0
      
      if s == 0
        r = g = b = l * 255
      else
        h /= 6.0
        t2 = l < 0.5 ? l * (s + 1) : (l + s) - (l * s)
        t1 = 2 * l - t2
        
        r = h + (1.0 / 3.0)
        g = h
        b = h - (1.0 / 3.0)
        
        r = hue_calc(r, t1, t2)
        g = hue_calc(g, t1, t2)
        b = hue_calc(b, t1, t2)
        
        @red = r * 255.0
        @green = g * 255.0
        @blue = b * 255.0
      end
    end
    
    def hue_calc(value, t1, t2)
      value += 1 if value < 0
      value -= 1 if value > 1
      return (t1 + (t2 - t1) * 6 * value) if 6 * value < 1
      return t2 if 2 * value < 1
      return (t1 + (t2 - t1) * (2.0 / 3.0 - value) * 6) if 3 * value < 2
      return t1;
    end
    
    def range_validator(val, range)
      range.include?(val) ? val : raise(ArgumentError, "Component range exceeded")
    end
  end
end
