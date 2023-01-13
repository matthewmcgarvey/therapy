require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.string.optional.coercing
    a.parse!("abc").should eq("abc")
    a.parse!(nil).should eq(nil)
    a.parse!(5).should eq("5")

    b = Therapy.int32.coercing
    b.parse!(5).should eq(5)
    b.parse!("5").should eq(5)
    b.parse!(true).should eq(1)

    b1 = Therapy.int32
    b1.parse!(5).should eq(5)
    expect_raises(Exception) { b1.parse!("5") }
    expect_raises(Exception) { b1.parse!(nil) }

    c = Therapy.string.min(2)
    c.parse!("abc").should eq("abc")
    expect_raises(Exception) { c.parse!("a") }
  end
end
