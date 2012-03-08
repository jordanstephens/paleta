require 'spec_helper'

describe Paleta::Palette do
  
  it "should initialize with a set of Colors" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    Paleta::Palette.new(c1, c2)
  end
  
  it "should not initialize if an object in the set is not a Color" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = 13
    expect{ Paleta::Palette.new(c1, c2) }.to raise_error(ArgumentError)
  end
  
  it "should add Colors" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    c3 = Paleta::Color.new(0, 0, 0)
    palette = Paleta::Palette.new(c1)
    palette << c2 << c3
    palette.include?(c2).should be_true
  end
  
  it "should add Colors with push" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1)
    palette.push(c2)
    palette[1].should == c2
  end
  
  it "should remove the last Color with pop" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)
    c = palette.pop()
    c.should == c2
    palette.include?(c2).should be_false
  end
  
  it "should remove Colors by index" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)
    palette.delete_at(0)
    palette.include?(c1).should be_false
  end
  
  it "should allow array-style accessing of Colors" do
    c1 = Paleta::Color.new(13, 57, 182)
    palette = Paleta::Palette.new(c1)
    palette[0].should == c1
    palette[1].should be_nil
  end
  
  it "should lighten each Color in a Palette by a percentage" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)
    lightness1 = c1.lightness
    lightness2 = c2.lightness
    percent = 20
    palette.lighten!(percent)
    palette[0].lightness.should == lightness1 + percent
    palette[1].lightness.should == lightness2 + percent
  end
  
  it "should darken each Color in a Palette by a percentage" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)
    lightness1 = c1.lightness
    lightness2 = c2.lightness
    percent = 20
    palette.darken!(percent)
    palette[0].lightness.should == lightness1 - percent
    palette[1].lightness.should == lightness2 - percent
  end
  
  it "should invert each Color in a Palette" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1, c2)
    palette.invert!
    palette[0].red.should == 242
    palette[0].green.should == 198
    palette[0].blue.should == 73
    palette[1].red.should == 161
    palette[1].green.should == 94
    palette[1].blue.should == 20
  end
  
  it "should calculate a multiple regression over each Color in the Palette in RGB space" do
    Paleta::Palette.send(:public, :fit)
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    c3 = Paleta::Color.new(237, 172, 33)
    palette = Paleta::Palette.new(c1, c2, c3)
    r = palette.fit
    r[:slope][:x].round(5).should == 0.19585
    r[:slope][:y].round(5).should == 0.52767
    r[:slope][:z].round(5).should == -0.11913
    r[:offset][:x].round(5).should == 127.54235
    r[:offset][:y].round(5).should == 50.84953
    r[:offset][:z].round(5).should == 130.15404
  end
  
  it "should calculate its similarity to another Palette" do
    c1 = Paleta::Color.new(0, 0, 0)
    p1 = Paleta::Palette.new(c1)
    
    c2 = Paleta::Color.new(255, 255, 255)
    p2 = Paleta::Palette.new(c2)
    
    p1.similarity(p2).should == 1
    
    c3 = Paleta::Color.new(0, 0, 0)
    c4 = Paleta::Color.new(255, 255, 255)
    p3 = Paleta::Palette.new(c3, c4)
    
    c5 = Paleta::Color.new(0, 0, 0)
    c6 = Paleta::Color.new(255, 255, 255)
    p4 = Paleta::Palette.new(c5, c6)
    p3.similarity(p4).should == 0
    
    c7 = Paleta::Color.new(13, 57, 182)
    c8 = Paleta::Color.new(237, 172, 33)
    p5 = Paleta::Palette.new(c7, c8)
    
    c9 = Paleta::Color.new(13, 57, 182)
    c10 = Paleta::Color.new(94, 161, 235)
    p6 = Paleta::Palette.new(c9, c10)
    p5.similarity(p6).round(5).should == 0.00669
  end
  
  it "should generate a new Palette of shades of a single Color" do
    color = Paleta::Color.new(:hex, "ff0000")
    palette = Paleta::Palette.generate(:from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |p|
      p.hue.should == color.hue
      p.saturation.should == color.saturation
    end
    palette[0].lightness.should == 10
    palette[1].lightness.should == 30
    palette[2].lightness.should == 50
    palette[3].lightness.should == 70
    palette[4].lightness.should == 90
  end
  
  it "should generate a new Palette of Colors analogous to the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :analogous, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |p|
      p.lightness.should == color.lightness
      p.saturation.should == color.saturation
    end
    palette[0].hue.should == 170
    palette[1].hue.should == 190
    palette[2].hue.should == 210
    palette[3].hue.should == 230
    palette[4].hue.should == 250
  end
  
  it "should generate a new Palette of Colors monochromatic to the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :monochromatic, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |p|
      p.hue.should == color.hue
      p.lightness.should == color.lightness
    end
    palette[0].saturation.should == 20
    palette[1].saturation.should == 40
    palette[2].saturation.should == 60
    palette[3].saturation.should == 80
    palette[4].saturation.should == 100
  end
  
  it "should generate a new Palette of random Colors" do
    palette = Paleta::Palette.generate(:type => :random, :size => 5)
    palette.size.should == 5
  end
  
  it "should generate a new complementary Palette from the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :complementary, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |c|
      c.lightness.should == color.lightness
      [color.hue, color.complement.hue].include?(c.hue).should be_true
    end
  end

  it "should generate a new triad Palette from the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :triad, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |c|
      c.lightness.should == color.lightness
      [color.hue, (color.hue + 120) % 360, (color.hue + 240) % 360].include?(c.hue).should be_true
    end
  end

  it "should generate a new tetrad Palette from the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :tetrad, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |c|
      c.lightness.should == color.lightness
      [color.hue, (color.hue + 90) % 360, (color.hue + 180) % 360, (color.hue + 270) % 360].include?(c.hue).should be_true
    end
  end
  
  it "should generate a new split-complement Palette from the seed Color" do
    color = Paleta::Color.new(:hex, "0066cc")
    palette = Paleta::Palette.generate(:type => :split_complement, :from => :color, :color => color, :size => 5)
    palette.size.should == 5
    palette.each do |c|
      c.lightness.should == color.lightness
      [color.hue, (color.hue + 150) % 360, (color.hue + 210) % 360].include?(c.hue).should be_true
    end
  end
  
  it "should generate a Palette from an image" do
    path = File.join(File.dirname(__FILE__), '..', 'images/test.jpg')
    size = 5
    palette = Paleta::Palette.generate(:from => :image, :image => path, :size => size)
    palette.size.should == size
  end
  
  it "should raise an error when generating a Palette from an invalid image" do
    expect{ Paleta::Palette.generate(:from => :image, :image => "/no/image.here") }.to raise_error(RuntimeError)
  end
end
