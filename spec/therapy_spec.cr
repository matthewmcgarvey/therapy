require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.string.coercing.optional
    a.parse!("abc").should eq("abc")
    a.parse!(nil).should eq(nil)
    a.parse!(5).should eq("5")

    b = Therapy.int32.coercing
    b.parse!(5).should eq(5)
    b.parse!("5").should eq(5)
    b.parse!(true).should eq(1)
    expect_raises(Exception) { b.parse!(nil) }

    b1 = Therapy.int32
    b1.parse!(5).should eq(5)
    expect_raises(Exception) { b1.parse!("5") }
    expect_raises(Exception) { b1.parse!(nil) }

    b2 = Therapy.int32.min(2).max(9)
    b2.parse!(2).should eq(2)
    b2.parse!(9).should eq(9)
    expect_raises(Exception) { b2.parse!(1) }
    expect_raises(Exception) { b2.parse!(10) }

    c = Therapy.string.min(2)
    c.parse!("abc").should eq("abc")
    expect_raises(Exception) { c.parse!("a") }

    d = Therapy.string.one_of("red", "yellow", "green")
    d.parse!("red").should eq("red")
    expect_raises(Exception) { d.parse!("blue") }

    e = Therapy.string.strip
    e.parse!("  input  ").should eq("input")

    f = Therapy.bool
    f.parse!(true).should eq(true)

    f1 = Therapy.bool.coercing
    f1.parse!(true).should eq(true)
    f1.parse!("true").should eq(true)
    f1.parse!("false").should eq(false)
  end
end
