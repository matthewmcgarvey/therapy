require "../spec_helper"

describe "unions" do
  it "string or bool" do
    validation = Therapy.string.or(Therapy.bool)

    validation.parse!("foo").should eq("foo")
    validation.parse!(true).should eq(true)
    validation.parse!("true").should eq("true")
    result = validation.parse!("abc")
    result.is_a?(String | Bool).should eq(true)
  end

  it "string or bool or int32" do
    validation = Therapy.string.or(Therapy.bool).or(Therapy.int(Int32))

    validation.parse!("foo").should eq("foo")
    validation.parse!(true).should eq(true)
    validation.parse!(123).should eq(123)
  end

  it "string or array of strings" do
    validation = Therapy.string.or(Therapy.array(Therapy.string))

    validation.parse!("foo").should eq("foo")
    validation.parse!(["foo", "bar"]).should eq(["foo", "bar"])

    validation2 = Therapy.array(Therapy.string).or(Therapy.string)

    validation2.parse!("foo").should eq("foo")
    validation2.parse!(["foo", "bar"]).should eq(["foo", "bar"])
  end

  it "object or object" do
    validation = Therapy.object(name: Therapy.string).or(Therapy.object(first_name: Therapy.string))

    validation.parse!({"name" => "Steve"}).should eq({name: "Steve"})
    validation.parse!({"first_name" => "Steve"}).should eq({first_name: "Steve"})
  end

  it "runs validations" do
    validation = Therapy.bool.or(Therapy.string.min(5))

    validation.parse!("Long String").should eq("Long String")
    validation.parse("Tiny").should be_error("Not coercable to bool, Must have minimum size of 5")
  end
end
