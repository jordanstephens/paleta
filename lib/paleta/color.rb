require 'paleta/core_ext/math'

module Paleta
  class Color
    include Math
    
    attr_reader :red, :green, :blue, :hue, :saturation, :lightness, :hex
    
    def initialize(*args)
      
      if args.length == 1 && args[0].is_a?(Color)
        # TODO: refactor this, find out how to call a method name by the value of a variable
        # something like args[0].instance_variables.each { |k, v| self.(k) = v }
        @red = args[0].red
        @green = args[0].green
        @blue = args[0].blue
        @hue = args[0].hue
        @saturation = args[0].saturation
        @lightness = args[0].lightness
        @hex = args[0].hex
      elsif args.length == 2 && args[0] == :hex && args[1].is_a?(String)
        # example: new(:hex, "336699")
        hex_init(args[1])
      elsif args.length == 3 && args[0].is_a?(Numeric) && args[1].is_a?(Numeric) && args[2].is_a?(Numeric)
        # example: new(235, 129, 74)
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
    
    def ==(color)
      color.is_a?(Color) ? (self.hex == color.hex) : false
    end
    
    def lighten(percent = 5)
      copy = self.class.new(self)
      copy.lighten!(percent)
      copy
    end
    
    def lighten!(percent = 5)
      @lightness += percent
      @lightness = 100 if @lightness > 100
      update_rgb
      update_hex
      self
    end
    
    def darken(percent = 5)
      copy = self.class.new(self)
      copy.darken!(percent)
      copy
    end
    
    def darken!(percent = 5)
      @lightness -= percent
      @lightness = 0 if @lightness < 0
      update_rgb
      update_hex
      self
    end
    
    def invert
      copy = self.class.new(self)
      copy.invert!
      copy
    end
    
    def invert!
      @red = 255 - @red
      @green = 255 - @green
      @blue = 255 - @blue
      update_hsl
      update_hex
      self
    end
    
    def desaturate
      copy = self.class.new(self)
      copy.desaturate!
      copy
    end
    
    def desaturate!
      @saturation = 0
      update_rgb
      update_hex
      self
    end
    
    def complement
      copy = self.class.new(self)
      copy.complement!
      copy
    end
    
    def complement!
      @hue = (@hue + 180) % 360
      update_rgb
      update_hex
      self
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
      
      h = 0
      l = (max + min) / 2.0
      s = ((l == 0 || l == 1) ? 0 : (delta / (1 - (2 * l - 1).abs)))

      if delta != 0
        case max
        when r; h = ((g - b) / delta) % 6
        when g; h = ((b - r) / delta) + 2
        when b; h = ((r - g) / delta) + 4
        end
      end
      
      @hue = h * 60
      @hue += 360 if @hue < 0
      @saturation = s * 100
      @lightness = l * 100
    end
    
    def update_rgb
            
      h = @hue / 60.0 rescue 0.0
      s = @saturation / 100.0 rescue 0.0
      l = @lightness / 100.0 rescue 0.0

      d1 = (1 - (2 * l - 1).abs) * s
      d2 = d1 * (1 - (h % 2 - 1).abs)
      d3 = l - (d1 / 2.0)
      
      case h.to_i
      when 0; @red, @green, @blue = d1, d2, 0
      when 1; @red, @green, @blue = d2, d1, 0
      when 2; @red, @green, @blue = 0, d1, d2
      when 3; @red, @green, @blue = 0, d2, d1
      when 4; @red, @green, @blue = d2, 0, d1
      when 5; @red, @green, @blue = d1, 0, d2
      else; @red, @green, @blue = 0, 0, 0
      end
      
      @red = 255 * (@red + d3)
      @green = 255 * (@green + d3)
      @blue = 255 * (@blue + d3)
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
    
    def range_validator(val, range)
      range.include?(val) ? val : raise(ArgumentError, "Component range exceeded")
    end
  end
end
