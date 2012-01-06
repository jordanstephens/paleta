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
  
  it "should calculate a multiple regression over each Color in the Palette in RGB space" do
    c1 = Paleta::Color.new(13, 57, 182)
    c2 = Paleta::Color.new(94, 161, 235)
    c3 = Paleta::Color.new(237, 172, 33)
    palette = Paleta::Palette.new(c1, c2, c3)
    r = palette.fit
    r.slope[:r].should == 0.4632575855725132
    r.slope[:g].should == -0.5730072013906133
    r.slope[:b].should == 0.06837037037037037
    r.offset[:r].should == 76.87979685435182
    r.offset[:g].should == 224.49093618077973
    r.offset[:b].should == 104.41111111111111
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
    p5.similarity(p6).round(5).should == 0.0047
  end
end
