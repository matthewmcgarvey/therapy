require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.from_nilable_string
    a.parse("hello").value.should eq("hello")
    a.parse(nil).value.should eq(nil)

    b = Therapy.from_nilable_string.presence.not_nil { "woops" }
    b.parse("hello").value.should eq("hello")
    b.parse(nil).value.should eq("woops")
    b.parse("").value.should eq("woops")

    c = Therapy.from_nilable_string.min_size(4) { |input| "Expected 4 got #{input.try &.size}" }
    c.parse("hello").value.should eq("hello")
    c.parse(nil).value.should eq(nil)
    c.parse("abc").value.should eq("Expected 4 got 3")

    d = Therapy.from_nilable_string.upcase
    d.parse("abc").value.should eq("ABC")
    d.parse(nil).value.should eq(nil)

    e = Therapy.from_nilable_string.downcase
    e.parse("ABC").value.should eq("abc")

    f = Therapy.from_nilable_string.not_nil { "woops" }.presence
    f.parse(nil).value.should eq("woops")
    f.parse("abc").value.should eq("abc")
    f.parse("").value.should eq(nil)

    g = Therapy.from_nilable_string.not_nil_or_blank { "woops" }
    g.parse("abc").value.should eq("abc")
    g.parse(nil).value.should eq("woops")
    g.parse("").value.should eq("woops")

    h = Therapy.from_nilable_string.boolean { "Must be true or false" }
    h.parse("true").value.should eq(true)
    h.parse("false").value.should eq(false)
    h.parse("abc").value.should eq("Must be true or false")
    h.parse(nil).value.should eq(nil)
    h.parse("true").value.should be_a(Bool?)

    h1 = Therapy.from_nilable_string.not_nil { "woops" }.boolean { "Must be true or false" }
    h1.parse("true").value.should eq(true)
    h1.parse("false").value.should eq(false)
    h1.parse("abc").value.should eq("Must be true or false")
    h1.parse(nil).value.should eq("woops")
    h1.parse("true").value.should be_a(Bool)

    i = Therapy.from_nilable_string.i32 { "Must be a number" }
    i.parse("123").value.should eq(123)
    i.parse("abc").value.should eq("Must be a number")

    j = Therapy.from_nilable_string.f64 { "Must be a number" }
    j.parse("9.99").value.should eq(9.99)
    j.parse("abc").value.should eq("Must be a number")

    k = Therapy.from_nilable_string.i32 { "asdf" }.min(0) { |input| "Min 0, Got #{input}" }
    k.parse("10").value.should eq(10)
    k.parse("-1").value.should eq("Min 0, Got -1")

    k1 = Therapy.from_nilable_string.f64 { "asdf" }.max(99.99) { |input| "Got #{input}" }
    k1.parse("98").value.should eq(98.0)
    k1.parse("100").value.should eq("Got 100.0")

    l = Therapy.from_nilable_string.with_default { "hello" }
    l.parse("goodbye").value.should eq("goodbye")
    l.parse(nil).value.should eq("hello")

    m = Therapy.from_nilable_string.map_input(->(input : NamedTuple(key: String)) { input[:key] })
    m.parse({key: "value"}).value.should eq("value")

    m1 = Therapy.from_nilable_string.map_input(Hash(String, String)) {|input| input["key"]}
    m1.parse({"key" => "value"}).value.should eq("value")
  end
end
