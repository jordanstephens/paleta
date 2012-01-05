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

    # create a color with RGB components
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
	
	# invert a color
	color.invert!
	
	# calculate similarity between Colors
	# Color#similarity calculates the similarity between two colors and returns a
	# value in 0..1, with 0 being identical and 1 being as dissimilar as possible
	color2 = Paleta::Color.new(237, 172, 33)
	color.similarity(color2) # => 0.5609077061558945
	
### Palette

	# add Colors to a Palette
    color1 = Paleta::Color.new(13, 57, 182)
    color2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)

	# retreive a Color from a Palette
	palette[1] # => color2

See the [documentation](http://rubydoc.info/gems/paleta/ "Documentation").

 