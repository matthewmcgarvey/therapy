require "../spec_helper"

describe Therapy::BoolType do
  it "coerces string to bool" do
    validation = Therapy.bool
    validation.parse!("true").should eq(true)
    validation.parse!("false").should eq(false)
  end
end
