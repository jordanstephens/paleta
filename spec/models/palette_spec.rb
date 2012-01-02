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
end
