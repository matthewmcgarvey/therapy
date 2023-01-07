require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.from_nilable_string
    a.parse("hello").should eq("hello")
    a.parse(nil).should eq(nil)

    b = Therapy.from_nilable_string.not_nil_or_blank { "woops" }
    b.parse("hello").should eq("hello")
    b.parse(nil).should eq("woops")
  end
end
