require 'paleta/core_ext/math'

module Paleta
  
  module MagickDependent
    def self.included(klass)
      require 'RMagick' unless defined?(Magick)
      klass.extend(ClassMethods)
    rescue LoadError
      puts "You must install RMagick to use Palette.generate(:from => :image, ...)"
    end
    
    module ClassMethods
      def generate_from_image(path, size = 5)
        include Magick
        begin
          image = Magick::ImageList.new(path)
          
          # quantize image to the nearest power of 2 greater the desired palette size
          quantized_image = image.quantize((Math.sqrt(size).ceil ** 2), Magick::RGBColorspace)
          colors = quantized_image.color_histogram.sort { |a, b| b[1] <=> a[1] }[0..(size - 1)].map do |color|          
            Paleta::Color.new(color[0].red / 256, color[0].green / 256, color[0].blue / 256)
          end
          return Paleta::Palette.new(colors)
        rescue Magick::ImageMagickError
          raise "Invalid image at " << path
        end
      end
    end
  end
  
  # Represents a palette, a collection of {Color}s
  class Palette
    include Math
    include Enumerable
    include MagickDependent
    
    attr_accessor :colors
    
    # Initialize a {Palette} from a list of {Color}s
    # @param [Array] colors a list of {Color}s to include in the {Palette}
    # @return [Palette] A new instance of {Palette}
    def initialize(*args)
      @colors = []
      colors = (args.length == 1 && args[0].is_a?(Array)) ? args[0] : args
      colors.each { |color| self << color }
    end
    
    # Add a {Color} to the {Palette}
    # @overload <<(color)
    #   @param [Color] color a {Color} to add to the receiver
    # @overload <<(palette)
    #   @param [Palette] palette a {Palette} to merge with the receiver
    # @return [Palette] self
    # @see Paleta::Palette.push(obj)
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
    
    # Add a {Color} to the {Palette}
    # @overload push(color)
    #   @param [Color] color a {Color} to add to the receiver
    # @overload push(palette)
    #   @param [Palette] palette a {Palette} to merge with the receiver
    # @return [Palette] self
    # @see Paleta::Palette.<<(obj)
    def push(obj)
      self << obj
    end
    
    # Remove the most recently added {Color} from the receiver
    def pop
      @colors.pop
    end
    
    # Remove a {Color} from the receiver by index
    # @param [Number] index the index at which to remove a {Color}
    def delete_at(index = 0)
      @colors.delete_at(index)
    end
    
    # Access a {Color} in the receiver by index
    # @param [Number] index the index at which to access a {Color}
    def [](index)
      @colors[index]
    end
    
    # The number of {Color}s in the {Palette}
    # @return [Number] the number of {Color}s in the receiver
    def size
      @colors.size
    end
    
    # Iterate through each {Color} in the {Palette}
    def each
      @colors.each { |c| yield c }
    end
    
    # Create a new instance of {Palette} that is a sorted copy of the receiver
    # @return [Palette] a new instance of {Palette}
    def sort(&blk)
      @colors.sort(&blk)
      Paleta::Palette.new(@colors)
    end
    
    # Sort the {Color}s in the receiver
    # return [Palette] self
    def sort!(&blk)
      @colors.sort!(&blk)
      self
    end
    
    # Test if a {Color} exists in the receiver
    # @param [Color] color color to test for inclusion in the {Palette}
    # @return [Boolean]
    def include?(color)
      @colors.include?(color)
    end
    
    # Lighen each {Color} in the receiver by a percentage
    # @param [Number] percentage percentage by which to lighten each {Color} in the receiver
    # @return [Palette] self
    def lighten!(percentage = 5)
      @colors.each { |color| color.lighten!(percentage) }
      self
    end
    
    # Lighen each {Color} in the receiver by a percentage
    # @param [Number] percentage percentage by which to lighten each {Color} in the receiver
    # @return [Palette] self
    def darken!(percentage = 5)
      @colors.each { |color| color.darken!(percentage) }
      self
    end
    
    # Invert each {Color} in the receiver by a percentage
    # @return [Palette] self
    def invert!
      @colors.each { |color| color.invert! }
      self
    end
    
    # Calculate the similarity between the receiver and another {Palette}
    # @param [Palette] palette palette to calculate the similarity to
    # @return [Number] a value in [0..1] with 0 being identical and 1 being as dissimilar as possible
    def similarity(palette)
      r, a, b = [], [], []
      (0..1).each { |i| a[i], b[i] = {}, {} }
      
      # r[i] is a hash of the multiple regression of the Palette in RGB space
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
    
    # Generate a {Palette} from a seed {Color}
    # @param [Hash] opts the options with which to generate a new {Palette}
    # @option opts [Symbol] :type the type of palette to generate
    # @option opts [Symbol] :from how to generate the {Palette}
    # @option opts [Color] :color if :from == :color, pass a {Color} object as :color
    # @option opts [String] :image if :from == :image, pass the path to an image as :image
    # @option opts [Number] :size the number of {Color}s to generate for the {Palette}
    # @return [Palette] A new instance of {Palette}
    def self.generate(opts = {})
      
      size = opts[:size] || 5
      
      if !opts[:type].nil? && opts[:type].to_sym == :random
        return self.generate_random_from_color(opts[:color], size)
      end
      
      unless (opts[:from].to_sym == :color && !opts[:color].nil?) || (opts[:from].to_sym == :image && !opts[:image].nil?)
        return raise(ArgumentError, 'You must pass :from and it must be either :color or :image, then you must pass :image => "/path/to/img" or :color => color')
      end
                  
      if opts[:from].to_sym == :image
        path = opts[:image]
        return self.generate_from_image(path, size)
      end
      
      color = opts[:color]
      type = opts[:type] || :shades
      
      case type
      when :analogous; self.generate_analogous_from_color(color, size)
      when :complementary; self.generate_complementary_from_color(color, size)
      when :monochromatic; self.generate_monochromatic_from_color(color, size)
      when :shades; self.generate_shades_from_color(color, size)
      when :split_complement; self.generate_split_complement_from_color(color, size)
      when :tetrad; self.generate_tetrad_from_color(color, size)
      when :triad; self.generate_triad_from_color(color, size)
      else raise(ArgumentError, "Palette type is not defined. Try :analogous, :monochromatic, :shades, or :random")
      end
    end
    
    # Return an array representation of a {Palette} instance,
    # @param [Symbol] model the color model, should be :rgb, :hsl, or :hex
    # @return [Array] an Array of Arrays where each sub-Array is a representation of a {Color} object in a {Palette} instance
    def to_array(color_model = :rgb)
      color_model = color_model.to_sym unless color_model.is_a? Symbol
      if [:rgb, :hsl].include?(color_model)
        array = colors.map { |c| c.to_array(color_model) }
      elsif color_model == :hex
        array = colors.map{ |c| c.hex }
      else
        raise(ArgumentError, "Argument must be :rgb, :hsl, or :hex")
      end
      array
    end
    
    private
    
    def self.generate_analogous_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      palette = self.new(color)
      step = 20
      below = (size / 2)
      above = (size % 2 == 0) ? (size / 2) - 1 : (size / 2)
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
      add_monochromatic_in_hues_of_color(palette, color, size)
    end
    
    def self.generate_triad_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      color2 = Paleta::Color.new(:hsl, (color.hue + 120) % 360, color.saturation, color.lightness)
      color3 = Paleta::Color.new(:hsl, (color2.hue + 120) % 360, color2.saturation, color2.lightness)
      palette = self.new(color, color2, color3)
      add_monochromatic_in_hues_of_color(palette, color, size)
    end
    
    def self.generate_tetrad_from_color(color, size)
      raise(ArgumentError, "Passed argument is not a Color") unless color.is_a?(Color)
      color2 = Paleta::Color.new(:hsl, (color.hue + 90) % 360, color.saturation, color.lightness)
      color3 = Paleta::Color.new(:hsl, (color2.hue + 90) % 360, color2.saturation, color2.lightness)
      color4 = Paleta::Color.new(:hsl, (color3.hue + 90) % 360, color3.saturation, color3.lightness)
      palette = self.new(color, color2, color3, color4)
      add_monochromatic_in_hues_of_color(palette, color, size)
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
      add_monochromatic_in_hues_of_color(palette, color, size)
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
      palette.sort! { |a, b| a.saturation <=> b.saturation }
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
