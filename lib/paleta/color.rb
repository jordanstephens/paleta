require 'paleta/core_ext/math'

module Paleta
  class Color
    include Math
    
    attr_reader :red, :green, :blue, :hue, :saturation, :lightness, :hex
    
    def initialize(*args)
      
      # example: new(:hex, "336699")
      if args.length == 2 && args[0] == :hex && args[1].is_a?(String)
        hex_init(args[1])
      # example: new(235, 129, 74)
      elsif args.length == 3 && args[0].is_a?(Numeric) && args[1].is_a?(Numeric) && args[2].is_a?(Numeric)
        rgb_init(args[0], args[1], args[2])
      elsif args.length == 4 && [:rgb, :hsl].include?(args[0]) && args[1].is_a?(Numeric) && args[2].is_a?(Numeric) && args[3].is_a?(Numeric)
        # example: new(:hsl, 320, 96, 74)
        rgb_init(args[1], args[2], args[3]) if args[0] == :rgb
        # example: new(:rgb, 235, 129, 74)
        hsl_init(args[1], args[2], args[3]) if args[0] == :hsl
      elsif args.length == 0
        # example: new()
        rgb_init(0, 0, 0)
      else
        raise(ArgumentError, "Invalid arguments")
      end
    end
    
    def rgb_init(red = 0, green = 0, blue = 0)
      self.red = red
      self.green = green
      self.blue = blue
    end
    
    def hsl_init(hue = 0, saturation = 0, lightness = 0)
      self.hue = hue
      self.saturation = saturation
      self.lightness = lightness
    end
    
    def hex_init(val = "000000")
      self.hex = val
    end
    
    def red=(val)
      @red = range_validator(val, 0..255)
      update_hsl
      update_hex
    end
    
    def green=(val)
      @green = range_validator(val, 0..255)
      update_hsl
      update_hex
    end
    
    def blue=(val)
      @blue = range_validator(val, 0..255)
      update_hsl
      update_hex
    end
    
    def lightness=(val)
      @lightness = range_validator(val, 0..100)
      update_rgb
      update_hex
    end
    
    def saturation=(val)
      @saturation = range_validator(val, 0..100)
      update_rgb
      update_hex
    end
    
    def hue=(val)
      @hue = range_validator(val, 0..360)
      update_rgb
      update_hex
    end
    
    def hex=(val)
      raise(ArgumentError, "Invalid Hex String") unless val.length == 6 && /^[[:xdigit:]]+$/ === val
      @hex = val.upcase
      @red = val[0..1].hex
      @green = val[2..3].hex
      @blue = val[4..5].hex
      update_hsl
    end
    
    def lighten!(percent = 5)
      @lightness += percent
      @lightness = 100 if @lightness > 100
      update_rgb
      update_hex
    end
    
    def darken!(percent = 5)
      @lightness -= percent
      @lightness = 0 if @lightness < 0
      update_rgb
      update_hex
    end
    
    def invert!
      @red = 255 - @red
      @green = 255 - @green
      @blue = 255 - @blue
      update_hsl
      update_hex
    end
    
    def similarity(color)
      distance({ :r => @red, :g => @green, :b => @blue}, { :r => color.red, :g => color.green, :b => color.blue}) / sqrt(3 * (255 ** 2))
    end
    
    private
    
    def update_hsl
      r = @red / 255.0 rescue 0.0
      g = @green / 255.0 rescue 0.0
      b = @blue / 255.0 rescue 0.0
      
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
      
      h = @hue / 360.0 rescue 0
      s = @saturation / 100.0 rescue 0
      l = @lightness / 100.0 rescue 0
      
      if s == 0
        @red = @green = @blue = l * 255
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
    
    def update_hex
      r = @red.to_i.to_s(16) rescue "00"
      g = @green.to_i.to_s(16) rescue "00"
      b = @blue.to_i.to_s(16) rescue "00"
      r = "0#{r}" if r.length < 2
      g = "0#{g}" if g.length < 2
      b = "0#{b}" if b.length < 2
      @hex = "#{r}#{g}#{b}".upcase
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
