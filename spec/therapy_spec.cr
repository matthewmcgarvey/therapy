require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.string.optional
    a.parse!("abc").should eq("abc")
    a.parse!(nil).should eq(nil)
    expect_raises(Exception) { a.parse!(5) }

    b = Therapy.int
    b.parse!(5).should eq(5)
    expect_raises(Exception) { b.parse!("5") }
    expect_raises(Exception) { b.parse!(true) }
    expect_raises(Exception) { b.parse!(nil) }

    b2 = Therapy.int.min(2).max(9)
    b2.parse!(2).should eq(2)
    b2.parse!(9).should eq(9)
    expect_raises(Exception) { b2.parse!(1) }
    expect_raises(Exception) { b2.parse!(10) }

    c = Therapy.string.min(2)
    c.parse!("abc").should eq("abc")
    expect_raises(Exception) { c.parse!("a") }

    d = Therapy.string.one_of("red", "yellow", "green")
    d.parse!("red").should eq("red")
    expect_raises(Exception) { d.parse!("blue") }

    e = Therapy.string.strip
    e.parse!("  input  ").should eq("input")

    f = Therapy.bool
    f.parse!(true).should eq(true)

    f1 = Therapy.bool
    f1.parse!(true).should eq(true)
    f1.parse!("true").should eq(true)
    f1.parse!("false").should eq(false)

    h = Therapy.object(key: f1)
    h.parse!({key: "true"}).should eq({key: true})

    # j
    admin_vali = Therapy.bool
    j = Therapy.object(admin: admin_vali)
    params = URI::Params.new({"admin" => ["true"]})
    j.parse!(params).should eq({admin: true})
    params2 = URI::Params.new(Hash(String, Array(String)).new)
    expect_raises(Exception) { j.parse!(params2) }
    hash1 = {"admin" => true}
    j.parse!(hash1).should eq({admin: true})

    # k
    k = Therapy.object(
      email: Therapy.string,
      password: Therapy.string,
      confirm: Therapy.string
    ).validate("Confirm must match password") do |form|
      form[:password] == form[:confirm]
    end
    json1 = JSON.parse({
      email:    "foo@example.com",
      password: "abc123",
      confirm:  "abc123",
    }.to_json)
    k.parse!(json1).should eq({
      email:    "foo@example.com",
      password: "abc123",
      confirm:  "abc123",
    })
    json2 = JSON.parse({
      password: "abc123",
      confirm:  "abc123",
    }.to_json)
    expect_raises(Exception) { k.parse!(json2) }
    json3 = JSON.parse({
      email:    5,
      password: "abc123",
      confirm:  "abc123",
    }.to_json)
    expect_raises(Exception) { k.parse!(json3) }
    json4 = JSON.parse({
      email:    "foo@example.com",
      password: "abc123",
      confirm:  "not-abc123",
    }.to_json)
    expect_raises(Exception) { k.parse!(json4) }

    # l
    l = Therapy.array(Therapy.string)
    l.parse!(["hello", "world"]).should eq(["hello", "world"])
    expect_raises(Exception) { l.parse!("not an array") }
    expect_raises(Exception) { l.parse!([1, 2]) }

    l1 = Therapy.array(Therapy.int)
    expect_raises(Exception) { l1.parse!(["1"]) }
    l1.parse!(JSON.parse([1].to_json)).should eq([1])

    # m
    m = Therapy.tuple(Therapy.string, Therapy.int)
    m.parse!(["hello", 42]).should eq({"hello", 42})

    m1 = Therapy.tuple(Therapy.string, Therapy.int)
    m1.parse!(JSON.parse(["hello", 42].to_json)).should eq({"hello", 42})

    # n
    n = Therapy.object(
      roles: Therapy.array(Therapy.string)
    )
    n.parse!({roles: ["admin"]}).should eq({roles: ["admin"]})
    n.parse!(JSON.parse({roles: ["admin"]}.to_json)).should eq({roles: ["admin"]})

    n1 = Therapy.object(
      users: Therapy.array(
        Therapy.object(
          name: Therapy.string,
          email: Therapy.string
        )
      )
    )
    expected = {
      users: [
        {
          name:  "Mike Tyson",
          email: "foo@example.com",
        },
        {
          name:  "Jason Bourne",
          email: "bar@example.com",
        },
      ],
    }
    n1.parse!(JSON.parse(expected.to_json)).should eq(expected)
  end
end
