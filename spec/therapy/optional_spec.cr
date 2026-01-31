require "../spec_helper"

describe Therapy::OptionalType do
  it "handles string" do
    validation = Therapy.string.optional

    validation.parse!("abc").should eq("abc")
    validation.parse!(nil).should eq(nil)
  end

  it "handles string with validation" do
    validation = Therapy.string.min(5).optional

    validation.parse!("abcdef").should eq("abcdef")
    validation.parse("abc").should be_error("Must have minimum size of 5")
    validation.parse!(nil).should eq(nil)
  end

  it "handles bool" do
    validation = Therapy.bool.optional

    validation.parse!("true").should eq(true)
    validation.parse!(false).should eq(false)
    validation.parse!(nil).should eq(nil)
  end
end
