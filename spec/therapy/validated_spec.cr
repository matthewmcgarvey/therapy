require "../spec_helper"

describe Therapy::Validated do
  it "works" do
    valid = Therapy::Validated::Valid(String, String).new("abc")
    valid.value.should eq("abc")
    valid.valid?.should eq(true)
    valid.map { |input| input * 2 }.value.should eq("abcabc")

    invalid = Therapy::Validated::Invalid(String, String).new("wrong")
    invalid.valid?.should eq(false)
    invalid.invalid?.should eq(true)
    invalid.value.should eq("wrong")
    invalid.or_else { Therapy::Validated::Valid(String, String).new("something happened") }.value.should eq("something happened")

    new_valid = valid.flat_map { |val| Therapy::Validated::Valid(String, Bool).new(true) }
    new_valid.valid?.should eq(true)
    new_valid.value.should eq(true)

    invalid.redeem(
      ->(input : String) { input.size },
      ->(input : String) { 23 }
    ).value.should eq(5)
  end
end
