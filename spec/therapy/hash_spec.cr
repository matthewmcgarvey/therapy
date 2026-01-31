require "../spec_helper"

describe "hashes" do
  it "string keys to int values" do
    validation = Therapy.hash(Therapy.string, Therapy.int(Int32))

    validation.parse!({"a" => 1, "b" => 2}).should eq({"a" => 1, "b" => 2})
  end

  it "validates values" do
    validation = Therapy.hash(Therapy.string, Therapy.string.min(3))

    validation.parse({"a" => "ok"}).should be_error
    validation.parse!({"a" => "long enough"}).should eq({"a" => "long enough"})
  end

  it "validates keys" do
    validation = Therapy.hash(Therapy.string.min(2), Therapy.int(Int32))

    validation.parse({"a" => 1}).should be_error
    validation.parse!({"long enough" => 1}).should eq({"long enough" => 1})
  end

  it "parses from json" do
    validation = Therapy.hash(Therapy.string, Therapy.int(Int32))
    input = JSON.parse(%({"a": 1, "b": 2}))

    validation.parse!(input).should eq({"a" => 1, "b" => 2})
  end

  it "parses from uri params" do
    validation = Therapy.hash(Therapy.string, Therapy.string)
    input = URI::Params.parse("a=1&b=2")

    validation.parse!(input).should eq({"a" => "1", "b" => "2"})
  end
end
