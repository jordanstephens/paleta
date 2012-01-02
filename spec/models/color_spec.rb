require 'spec_helper'

describe Paleta::Color do
  it "should initialize with components in 0..255" do
    color = Paleta::Color.new(94, 161, 235)
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end
  
  it "should not initialize with components not in 0..255" do
    expect{ Paleta::Color.new(-74, 333, 4321) }.to raise_error
  end
  
  it "should calculate its HSL value on itialization" do
    color = Paleta::Color.new(237, 172, 33)
    color.hue.to_i.should == 40
    color.saturation.to_i.should == 85
    color.lightness.to_i.should == 52
  end
  
  it "should update its HSL value when its RGB values are updated" do
    color = Paleta::Color.new(237, 172, 33)
    color.red = 0
    color.hue.to_i.should == 131
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 33
    
    color.green = 123
    color.hue.to_i.should == 136
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 24

    color.blue = 241
    color.hue.to_i.should == 209
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 47
  end
end
