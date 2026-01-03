require "../spec_helper"

describe Therapy::OptionalType do
  it "handles present string" do
    validation = Therapy.string.optional

    validation.parse!("abc").should eq("abc")
  end

  it "handles missing string" do
    validation = Therapy.string.optional

    validation.parse!(nil).should eq(nil)
  end

  it "handles string with validation" do
    validation = Therapy.string.min(5).optional

    validation.parse!("abcdef").should eq("abcdef")
    validation.parse("abc").should be_error("Must have minimum size of 5")
  end

  it "handles bool coerced from string" do
    validation = Therapy.bool.optional

    validation.parse!("true").should eq(true)
  end
end
