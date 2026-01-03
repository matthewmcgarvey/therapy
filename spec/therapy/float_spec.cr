require "../spec_helper"

describe Therapy::FloatType do
  it "can handle json" do
    validation = Therapy.float

    validation.parse!(JSON::Any.new(1.234)).should eq(1.234)
  end

  it "can handle different float types" do
    validation = Therapy.float(Float64)

    # have to round otherwise the conversion has differences in the very small decimal places
    validation.parse!(1.2_f32).round(2).should eq(1.2)
  end
end
