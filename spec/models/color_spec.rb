require 'spec_helper'

describe Paleta::Color do
  it "should initialize with components in 0..255" do
    color = Paleta::Color.new(22, 33, 44)
    color.red.should == 22
    color.green.should == 33
    color.blue.should == 44
  end
  
  it "should not initialize with components not in 0..255" do
    expect{ Paleta::Color.new(-74, 333, 4321) }.to raise_error
  end
end
