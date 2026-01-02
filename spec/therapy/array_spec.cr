require "../spec_helper"

describe Therapy::ArrayType do
  it "handles JSON::Any" do
    json = JSON.parse("[\"admin\", \"user\"]")
    validation = Therapy.array(Therapy.string)

    validation.parse!(json).should eq(["admin", "user"])
  end
end
