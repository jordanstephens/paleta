# Paleta

[![Build Status](https://travis-ci.org/jordanstephens/paleta.svg?branch=master)](https://travis-ci.org/jordanstephens/paleta)
[![Code Climate](https://codeclimate.com/github/jordanstephens/paleta/badges/gpa.svg)](https://codeclimate.com/github/jordanstephens/paleta)
[![Dependency Status](https://gemnasium.com/jordanstephens/paleta.svg)](https://gemnasium.com/jordanstephens/paleta)


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

Paleta allows users to create Color objects. Color objects can be defined by HSL, RGB or HEX values and can be manipulated and compared.

#### Creating Colors

Colors can be created using RGB or HSL components, or by using a HEX value by passing in a flag of the desired format as the first parameter. If no format flag is used, RGB is assumed.

```ruby
color = Paleta::Color.new(:hsl, 280, 37, 68)
color = Paleta::Color.new(:rgb, 94, 161, 235)
color = Paleta::Color.new(:hex, "5EA1EB")

# creating a Color with no flag defaults to RGB components

color = Paleta::Color.new(94, 161, 235)
```

Individual component values can be accessed by name

```ruby
color.red # => 94
color.green # => 161
color.blue # => 235
color.hue # => 211.48936170212767
color.saturation # => 77.90055248618782
color.lightness # => 64.50980392156862
color.hex # => "5EA1EB"
```	
	
Get an array representation of a Color

```ruby
c = Paleta::Color.new(30, 90, 120)
c.to_array(:rgb) # => [30, 90, 120]
```

#### Manipulating Colors


Colors can be lightened or darkened by a percentage

```ruby
color.lighten!(10) 
color.darken!(30) 
```

Colors can be desaturated

```ruby
color.desaturate!
```

Colors can be turned into their complement Colors

```ruby
color.complement!
```

Colors can be inverted

```ruby
color.invert!
```

**Note** all of the previous methods directly manipulate the object on which they were called. If you would like to create a new Color object that is a copy of the original color (but with the desired manipulation), call the desired method without the trailing bang `!`.

For example, lets create a new Color that is the complement of a Color we have already defined.

```ruby
new_color = color.complement
```

#### Comparing Colors

Colors can calculate their similarity to other Colors. The `similarity` method returns a value between 0 and 1, with 0 being identical and 1 being as dissimilar as possible.

```ruby
color = Paleta::Color.new(:hsl, 280, 37, 68)
color2 = Paleta::Color.new(237, 172, 33)
color.similarity(color2) # => 0.4100287904421024
```

### Palette

Palettes are collections of Colors, they share many common Array methods such as `push`, `pop`, `sort`, `include?` and `each`. Palettes also allow collections of Colors to be manipulated as a whole and to be compared to each other.

#### Creating a Palette

Palettes can be created by passing a list of Colors to the Palette constructor, or on the fly with `push` and `<<`. 

```ruby
color1 = Paleta::Color.new(13, 57, 182)
color2 = Paleta::Color.new(94, 161, 235)
color3 = Paleta::Color.new(237, 182, 17)
palette = Paleta::Palette.new(color1, color2)

palette << color3
```

#### Retrieving and Removing Colors from Palettes

Colors can be accessed and removed by index.
	
```ruby
palette[1] # => color2

palette.delete_at(2)
```

Get an array representation of a Palette

```ruby
c1 = Paleta::Color.new(13, 57, 182)
c2 = Paleta::Color.new(94, 161, 235)
palette = Paleta::Palette.new(c1, c2)
	
palette.to_array(:rgb) # => [[13, 57, 182], [94, 161, 235]]
```

#### Manipulating Palettes

Palettes can be lightened, darkened or inverted as a whole.

```ruby
palette.lighten!(15)
palette.darken!(20)
palette.invert!
```

#### Comparing Palettes

Palettes can calculate their similarity to other Palettes by using the `similarity` method. Just as with `Color#similarity`, this method returns a value between 0 and 1, with 0 being identical and 1 being as dissimilar as possible. 

```ruby
color1 = Paleta::Color.new(13, 57, 182)
color2 = Paleta::Color.new(237, 172, 33)
palette1 = Paleta::Palette.new(color1, color2)

color3 = Paleta::Color.new(13, 57, 182)
color4 = Paleta::Color.new(94, 161, 235)
palette2 = Paleta::Palette.new(color3, color4)

palette1.similarity(palette2) # => 0.0046992695975874915
```

#### Generating Palettes

Palettes can be generated from a "seed" Color or from an image by using the `generate` method.
	
**Generate a Palette of shades from a Color**

```ruby
color = Paleta::Color.new(:hex, "ff0000")
palette = Paleta::Palette.generate(:type => :shades, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of analogous Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "0066cc")
palette = Paleta::Palette.generate(:type => :analogous, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of monochromatic Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "336699")
palette = Paleta::Palette.generate(:type => :monochromatic, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of complementary Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "0000ff")
palette = Paleta::Palette.generate(:type => :complementary, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of split-complement Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "006699")
palette = Paleta::Palette.generate(:type => :split_complement, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of triad Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "006699")
palette = Paleta::Palette.generate(:type => :triad, :from => :color, :size => 5, :color => color)
```

**Generate a Palette of tetrad Colors from a Color**

```ruby
color = Paleta::Color.new(:hex, "dd5533")
palette = Paleta::Palette.generate(:type => :tetrad, :from => :color, :size => 5, :color => color)
```

**Generate a random Palette**

```ruby
palette = Paleta::Palette.generate(:type => :random, :size => 5)
```

Palettes can also be generated from a seed image
	
**Generate a Palette from an image**

```ruby
palette = Paleta::Palette.generate(:from => :image, :image => "/path/to/image.jpg", :size => 5)
```

***

See the [documentation](http://rubydoc.info/gems/paleta/ "Documentation").

