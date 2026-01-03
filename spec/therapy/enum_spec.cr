require "../spec_helper"
require "../support/enums"

describe Therapy::EnumType do
  it "can coerce a string" do
    validation = Therapy.enum(Color)

    validation.parse!("Red").should eq(Color::Red)
    validation.parse!("GREEN").should eq(Color::Green)
    validation.parse!("blue").should eq(Color::Blue)
    validation.parse("orange").should be_error("Must be one of Red, Green, Blue")
  end

  it "can coerce an int" do
    validation = Therapy.enum(Color)

    validation.parse!(0).should eq(Color::Red)
    validation.parse(20).should be_error("Must be one of 0, 1, 2")
  end

  it "can coerce json" do
    validation = Therapy.enum(Color)

    validation.parse!(JSON::Any.new("Red")).should eq(Color::Red)
  end
end
