require 'paleta/core_ext/math'

module Paleta
  class Palette
    include Math
    
    attr_accessor :colors
    
    def initialize(*colors)
      @colors = []
      colors.each do |color|
        self << color
      end
    end
    
    def <<(color)
      color.is_a?(Color) ? @colors << color : raise(ArgumentError, "Passed argument is not a Color")
      self
    end
    
    def push(color)
      self << color
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
      r[0] = self.fit
      r[1] = palette.fit
      
      [0, 1].each do |i|
        [:r, :g, :b].each do |k|
          a[i][k] = 0 * r[i].slope[k] + r[i].offset[k]
          b[i][k] = 255 * r[i].slope[k] + r[i].offset[k]
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
      when :random; self.generate_random_palette_from_color(color, size)
      else self.generate_shades_palette_from_color(color, size)
      end
    end
    
    def self.generate_shades_palette_from_color(color, n = 5)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      palette = self.new(color)
      step = (100 / n)
      lightness = color.lightness
      d = :down
      until palette.size == n
        lightness -= step if d == :down
        lightness += step if d == :up
        palette << Paleta::Color.new(:hsl, color.hue, color.saturation, lightness)
        if lightness - step < 0
          d = :up
          lightness = color.lightness
        end
      end
      palette.colors.sort! { |a, b| a.lightness <=> b.lightness }
    end
    
    private
    
    def fit
      # create a 3xn matrix where n = @colors.size to represent the set of colors
      reds = @colors.map { |c| c.red }
      greens = @colors.map { |c| c.green }
      blues = @colors.map { |c| c.blue }
      MultipleRegression.new(reds, greens, blues)
    end
  end
end
