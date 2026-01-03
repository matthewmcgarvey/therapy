require "../spec_helper"

describe Therapy::ArrayType do
  it "handles JSON::Any" do
    json = JSON.parse("[\"admin\", \"user\"]")
    validation = Therapy.array(Therapy.string)

    validation.parse!(json).should eq(["admin", "user"])
  end

  it "handles coercing bool elements from string" do
    validation = Therapy.array(Therapy.bool)

    validation.parse!(["true", "false"]).should eq([true, false])
  end

  it "handles input with correct type but breaking validation rules" do
    validation = Therapy.array(Therapy.string.min(5))

    validation.parse(["abc"]).should be_error("[0]: Must have minimum size of 5")
  end
end
