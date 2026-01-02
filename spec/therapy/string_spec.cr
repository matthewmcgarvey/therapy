require "../spec_helper"

describe Therapy::StringType do
  it "can't be nil by default" do
    validation = Therapy.string
    # validation.parse!("im a string").should eq("im a string")
    validation.parse(nil).should be_error("Expected String got Nil")
  end

  it "can be optional" do
    validation = Therapy.string.optional
    validation.parse!("abc").should eq("abc")
    validation.parse!(nil).should eq(nil)
  end

  it "can have min size" do
    validation = Therapy.string.min(2)
    validation.parse!("clearly long string").should eq("clearly long string")
    validation.parse!("aa").should eq("aa")
    validation.parse("a").should be_error("Must have minimum size of 2")
  end

  it "can have max size" do
    validation = Therapy.string.max(5)
    validation.parse!("tiny").should eq("tiny")
    validation.parse!("small").should eq("small")
    validation.parse("too big").should be_error("Must have maximum size of 5")
  end

  it "can have exact size" do
    validation = Therapy.string.size(5)
    validation.parse!("12345").should eq("12345")
    validation.parse("1234").should be_error("Must have exact size of 5")
    validation.parse("123456").should be_error("Must have exact size of 5")
  end

  it "can be one of a list of options" do
    validation = Therapy.string.one_of("red", "yellow", "green")
    validation.parse!("red").should eq("red")
    validation.parse!("green").should eq("green")
    validation.parse("blue").should be_error("Must be one of: red, yellow, green")

    validation1 = Therapy.string.one_of(["a", "b", "c"])
    validation1.parse!("a").should eq("a")
    validation1.parse!("c").should eq("c")
    validation1.parse("d").should be_error("Must be one of: a, b, c")
  end

  it "can be coerced from json" do
    json = JSON::Any.new("value")
    validation = Therapy.string
    validation.parse!(json).should eq("value")

    json1 = JSON::Any.new(123)
    validation.parse(json1).should be_error("Expected String got Int64")
  end
end
