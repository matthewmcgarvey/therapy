require "../spec_helper"

describe Therapy::TupleType do
  it "handles an array" do
    validation = Therapy.tuple(Therapy.string, Therapy.int32)

    validation.parse!(["hello", 42]).should eq({"hello", 42})
  end

  it "handles json" do
    json = JSON.parse(%{[true, "hello"]})
    validation = Therapy.tuple(Therapy.bool, Therapy.string)

    validation.parse!(json).should eq({true, "hello"})
  end

  it "handles nested validations" do
    validation = Therapy.tuple(Therapy.string.min(5))

    validation.parse(["abc"]).should be_error("[0]: Must have minimum size of 5")
  end

  it "has appropriate error when array size doesn't match" do
    validation = Therapy.tuple(Therapy.int32, Therapy.int32)

    validation.parse([1, 2, 3]).should be_error("Must have size of 2 but was 3")
    validation.parse([1]).should be_error("Must have size of 2 but was 1")
  end
end
