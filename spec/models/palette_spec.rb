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
    expect{ Paleta::Palette.new(c1, c2) }.to raise_error
  end
  
  it "should add colors to an initialized palette" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    palette = Paleta::Palette.new(c1)
    palette << c2
    palette.include?(c2).should be_true
  end
  
  it "should allow array-style accessing of colors" do
    c1 = Paleta::Color.new(13, 57, 182)
    palette = Paleta::Palette.new(c1)
    palette[0].should == c1
    palette[1].should be_nil
  end
  
  it "should lighten each color in a palette by a percentage" do
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
  
  it "should darken each color in a palette by a percentage" do
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
  
  it "should invert each color in a palette" do
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
end
