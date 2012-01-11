# Paleta

A gem for working with color palettes

## Installation

To install, run

    $ gem install paleta
	
Or, add this to your application's Gemfile

``` ruby
gem 'paleta'
```

and run

    $ bundle
	
## Usage

### Color

	# create a Color with HSL components
	color = Paleta::Color.new(:hsl, 280, 37, 68)
	
	# create a Color with RGB components
	color = Paleta::Color.new(:rgb, 94, 161, 235)
	
	# create a Color with a HEX value
	color = Paleta::Color.new(:hex, "5EA1EB")
	
    # creating a Color with no flag defaults to RGB components
	color = Paleta::Color.new(94, 161, 235)
	
	# access component values
	color.red # => 94
	color.green # => 161
	color.blue # => 235
	
	# HSL components are maintained too!
	color.hue # => 211.48936170212767
	color.saturation # => 77.90055248618782
	color.lightness # => 64.50980392156862
	
	# a HEX value is also maintained for each Color
	color.hex # => "5EA1EB"
	
	# lighten by a percentage
	color.lighten!(10) 
	
	# darken by a percentage
	color.darken!(10) 
	
	# desaturate a Color
	color.desaturate!
	
	# convert a Color into its complement
	color.complement!
	
	# invert a Color
	color.invert!
	
	# calculate similarity between Colors
	# Color#similarity calculates the similarity between two Colors and returns a
	# value in 0..1, with 0 being identical and 1 being as dissimilar as possible
	color2 = Paleta::Color.new(237, 172, 33)
	color.similarity(color2) # => 0.5609077061558945
	
### Palette

	# add Colors to a Palette
    color1 = Paleta::Color.new(13, 57, 182)
    color2 = Paleta::Color.new(94, 161, 235)
	color3 = Paleta::Color.new(237, 182, 17)
    palette = Paleta::Palette.new(color1, color2)
	
	# add Colors to a Palette
	palette << color3
	
	# retreive a Color from a Palette
	palette[1] # => color2
	
	# remove a Color from a Palette by index
	palette.delete_at(2)
	
	# lighten and darken an entire Palette by a percentage
	palette.lighten!(15)
	palette.darken!(20)

	# invert each color in a Palette
	palette.invert!
	
	# calculate similarity of two Palettes
    color1 = Paleta::Color.new(13, 57, 182)
    color2 = Paleta::Color.new(237, 172, 33)
    palette1 = Paleta::Palette.new(color1, color2)
    
    color3 = Paleta::Color.new(13, 57, 182)
    color4 = Paleta::Color.new(94, 161, 235)
    palette2 = Paleta::Palette.new(color3, color4)

	# Palette#similarity calculates the similarity between two Palettes and returns a
	# value in 0..1, with 0 being identical and 1 being as dissimilar as possible	
    palette1.similarity(palette2) # => 0.0046992695975874915
	
	# generate random Palette
	palette = Paleta::Palette.generate(:type => :random, :size = 5)
	
	# generate a Palette of shades from a Color
	color = Paleta::Color.new(:hex, "ff0000")
	palette = Paleta::Palette.generate(:type => :shades, :from => color, :size => 5)
	
	# generate a Palette of Colors analogous to the seed Color
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :analogous, :from => color, :size => 5)
	
	# generate a Palette of Colors monochromatic to the seed Color
    color = Paleta::Color.new(:hex, "336699")
    palette = Paleta::Palette.generate(:type => :monochromatic, :from => color, :size => 5)
	
See the [documentation](http://rubydoc.info/gems/paleta/ "Documentation").

 