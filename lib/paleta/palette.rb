module Paleta
  class Palette
    
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
    
    def include?(color)
      @colors.include?(color)
    end
  end
end
