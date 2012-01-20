require 'paleta/core_ext/math'

module Paleta
  class Palette
    include Math
    include Enumerable
    
    attr_accessor :colors
    
    def initialize(*args)
      @colors = []
      colors = (args.length == 1 && args[0].is_a?(Array)) ? args[0] : args
      colors.each do |color|
        self << color
      end
    end
    
    def <<(obj)
      if obj.is_a?(Color)
        @colors << obj
      elsif obj.is_a?(Palette)
        @colors |= obj.colors
      else
        raise(ArgumentError, "Passed argument is not a Color")
      end
      self
    end
    
    def push(obj)
      self << obj
    end
    
    def pop
      @colors.pop
    end
    
    def delete_at(i = 0)
      @colors.delete_at(i)
    end
    
    def [](i)
      @colors[i]
    end
    
    def size
      @colors.size
    end
    
    def each
      @colors.each { |c| yield c }
    end
    
    def sort &blk
      @colors.sort &blk
      Paleta::Palette.new(@colors)
    end
    
    def sort! &blk
      @colors.sort! &blk
      self
    end
    
    def include?(color)
      @colors.include?(color)
    end
    
    def lighten!(percent = 5)
      @colors.each do |color|
        color.lighten!(percent)
      end
    end
    
    def darken!(percent = 5)
      @colors.each do |color|
        color.darken!(percent)
      end
    end
    
    def invert!
      @colors.each do |color|
        color.invert!
      end
    end
    
    def similarity(palette)
      r, a, b = [], [], []
      (0..1).each { |i| a[i], b[i] = {}, {} }
      
      # r[i] is the Math::MultipleRegression of the Palette in RGB space
      r[0] = fit
      r[1] = palette.fit
            
      [0, 1].each do |i|
        [:x, :y, :z].each do |k|
          a[i][k] = 0 * r[i][:slope][k] + r[i][:offset][k]
          b[i][k] = 255 * r[i][:slope][k] + r[i][:offset][k]
        end
      end
      
      d_max = sqrt(3 * (65025 ** 2))
     
      d1 = distance(a[0], a[1]) / d_max
      d2 = distance(b[0], b[1]) / d_max
      
      d1 + d2
    end
    
    def self.generate(opts = {})
      raise(ArgumentError, "Pass a Color using :from, generate( :from => Color )") if opts.empty?
      color = opts[:from]
      type = opts[:type] || :shades
      size = opts[:size] || 5
      case type
      when :analogous; self.generate_analogous_from_color(color, size)
      when :complementary; self.generate_complementary_from_color(color, size)
      when :monochromatic; self.generate_monochromatic_from_color(color, size)
      when :random; self.generate_random_from_color(color, size)
      when :shades; self.generate_shades_from_color(color, size)
      when :split_complement; self.generate_split_complement_from_color(color, size)
      when :tetrad; self.generate_tetrad_from_color(color, size)
      when :triad; self.generate_triad_from_color(color, size)
      else raise(ArgumentError, "Palette type is not defined. Try :analogous, :monochromatic, :shades, or :random")
      end
    end
    
    private
    
    def self.generate_analogous_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      palette = self.new(color)
      step = 20
      below = (size / 2)
      above = (size % 2 == 0) ? (size / 2) - 1: (size / 2)
      below.times do |i|
        hue = color.hue - ((i + 1) * step)
        hue += 360 if hue < 0
        palette << Paleta::Color.new(:hsl, hue, color.saturation, color.lightness)
      end
      above.times do |i|
        hue = color.hue + ((i + 1) * step)
        hue -= 360 if hue > 360
        palette << Paleta::Color.new(:hsl, hue, color.saturation, color.lightness)
      end
      palette.sort! { |a, b| a.hue <=> b.hue }
    end
    
    def self.generate_complementary_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      complement = color.complement
      palette = self.new(color, complement)
      palette << add_monochromatic_in_hues_of_color(palette, color, size)
      palette.sort! { |a, b| a.saturation <=> b.saturation }
    end
    
    def self.generate_triad_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      color2 = Paleta::Color.new(:hsl, (color.hue + 120) % 360, color.saturation, color.lightness)
      color3 = Paleta::Color.new(:hsl, (color2.hue + 120) % 360, color2.saturation, color2.lightness)
      palette = self.new(color, color2, color3)
      palette << add_monochromatic_in_hues_of_color(palette, color, size)
      palette.sort! { |a, b| a.saturation <=> b.saturation }
    end
    
    def self.generate_tetrad_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      color2 = Paleta::Color.new(:hsl, (color.hue + 90) % 360, color.saturation, color.lightness)
      color3 = Paleta::Color.new(:hsl, (color2.hue + 90) % 360, color2.saturation, color2.lightness)
      color4 = Paleta::Color.new(:hsl, (color3.hue + 90) % 360, color3.saturation, color3.lightness)
      palette = self.new(color, color2, color3, color4)
      palette << add_monochromatic_in_hues_of_color(palette, color, size)
      palette.sort! { |a, b| a.saturation <=> b.saturation }
    end
    
    def self.generate_monochromatic_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      palette = self.new(color)
      step = (100 / size)
      saturation = color.saturation
      d = :down
      until palette.size == size
        saturation -= step if d == :down
        saturation += step if d == :up
        palette << Paleta::Color.new(:hsl, color.hue, saturation, color.lightness)
        if saturation - step < 0
          d = :up
          saturation = color.saturation
        end
      end
      palette.sort! { |a, b| a.saturation <=> b.saturation }
    end
    
    def self.generate_shades_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      palette = self.new(color)
      step = (100 / size)
      lightness = color.lightness
      d = :down
      until palette.size == size
        lightness -= step if d == :down
        lightness += step if d == :up
        palette << Paleta::Color.new(:hsl, color.hue, color.saturation, lightness)
        if lightness - step < 0
          d = :up
          lightness = color.lightness
        end
      end
      palette.sort! { |a, b| a.lightness <=> b.lightness }
    end
    
    def self.generate_split_complement_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      color2 = Paleta::Color.new(:hsl, (color.hue + 150) % 360, color.saturation, color.lightness)
      color3 = Paleta::Color.new(:hsl, (color2.hue + 60) % 360, color2.saturation, color2.lightness)
      palette = self.new(color, color2, color3)
      palette << add_monochromatic_in_hues_of_color(palette, color, size)
      palette.sort! { |a, b| a.saturation <=> b.saturation }
    end
    
    def self.generate_random_from_color(color = nil, size)
      palette = color.is_a?(Color) ? self.new(color) : self.new
      r = Random.new(Time.now.sec)
      until palette.size == size
        palette << Paleta::Color.new(r.rand(0..255), r.rand(0..255), r.rand(0..255))
      end
      palette
    end
    
    def self.add_monochromatic_in_hues_of_color(palette, color, size)
      raise(ArgumentError, "Second argument is not a Color") unless color.is_a?(Color)       
      hues = palette.map { |c| c.hue }
      step = ugap = dgap = 100 / size
      i = j = 0
      saturation = color.saturation
      until palette.size == size    
        if color.saturation + ugap < 100
          saturation = color.saturation + ugap
          ugap += step
        else
          saturation = color.saturation - dgap
          dgap += step
        end if j == 3 || j == 1
        new_color = Paleta::Color.new(:hsl, hues[i], saturation, color.lightness)        
        palette << new_color unless palette.include?(new_color)
        i += 1; j += 1; i %= hues.size; j %= (2 * hues.size)
      end
      palette
    end
    
    def fit
      # create a 3xn matrix where n = @colors.size to represent the set of colors
      reds = @colors.map { |c| c.red }
      greens = @colors.map { |c| c.green }
      blues = @colors.map { |c| c.blue }
      multiple_regression(reds, greens, blues)
    end
  end
end
