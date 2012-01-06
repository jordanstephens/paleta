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
      r1 = self.fit
      r2 = palette.fit
      
      a1, a2, b1, b2 = {}, {}, {}, {}
      a1[:r] = 0 * r1.slope[:r] + r1.offset[:r]
      a1[:g] = 0 * r1.slope[:g] + r1.offset[:g]
      a1[:b] = 0 * r1.slope[:b] + r1.offset[:b]
      b1[:r] = 255 * r1.slope[:r] + r1.offset[:r]
      b1[:g] = 255 * r1.slope[:g] + r1.offset[:g]
      b1[:b] = 255 * r1.slope[:b] + r1.offset[:b]
      a2[:r] = 0 * r2.slope[:r] + r2.offset[:r]
      a2[:g] = 0 * r2.slope[:g] + r2.offset[:g]
      a2[:b] = 0 * r2.slope[:b] + r2.offset[:b]
      b2[:r] = 255 * r2.slope[:r] + r2.offset[:r]
      b2[:g] = 255 * r2.slope[:g] + r2.offset[:g]
      b2[:b] = 255 * r2.slope[:b] + r2.offset[:b]

      d1 = sqrt(((a1[:r] - a2[:r]) ** 2) + ((a1[:g] - a2[:g]) ** 2) + ((a1[:b] - a2[:b]) ** 2)) / sqrt(3 * (65025 ** 2))
      d2 = sqrt(((b1[:r] - b2[:r]) ** 2) + ((b1[:g] - b2[:g]) ** 2) + ((b1[:b] - b2[:b]) ** 2)) / sqrt(3 * (65025 ** 2))
      
      d1 + d2
    end
        
    def fit
      # create a 3xn matrix where n = @colors.size to represent the set of colors
      reds = @colors.map { |c| c.red }
      greens = @colors.map { |c| c.green }
      blues = @colors.map { |c| c.blue }
      MultipleRegression.new(reds, greens, blues)
    end
  end
end
