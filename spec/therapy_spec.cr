require "./spec_helper"

describe Therapy do
  it "works" do
    a = Therapy.string.coercing.optional
    a.parse!("abc").should eq("abc")
    a.parse!(nil).should eq(nil)
    a.parse!(5).should eq("5")

    b = Therapy.int32.coercing
    b.parse!(5).should eq(5)
    b.parse!("5").should eq(5)
    b.parse!(true).should eq(1)
    expect_raises(Exception) { b.parse!(nil) }

    b1 = Therapy.int32
    b1.parse!(5).should eq(5)
    expect_raises(Exception) { b1.parse!("5") }
    expect_raises(Exception) { b1.parse!(nil) }

    b2 = Therapy.int32.min(2).max(9)
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

    f1 = Therapy.bool.coercing
    f1.parse!(true).should eq(true)
    f1.parse!("true").should eq(true)
    f1.parse!("false").should eq(false)

    h = Therapy.object(key: f1).coercing
    h.parse!({key: "true"}).should eq({key: true})

    # j
    admin_vali = Therapy.bool.coercing
    j = Therapy.object(admin: admin_vali).coercing
    params = URI::Params.new({"admin" => ["true"]})
    j.parse!(params).should eq({admin: true})
    params2 = URI::Params.new(Hash(String, Array(String)).new)
    expect_raises(Exception) { j.parse!(params2) }
    hash1 = {"admin" => true}
    j.parse!(hash1).should eq({admin: true})

    # k
    email_vali = Therapy.string
    password_vali = Therapy.string
    confirm_vali = Therapy.string
    k = Therapy.object(
      email: email_vali,
      password: password_vali,
      confirm: confirm_vali
    ).coercing
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
      email: 5,
      password: "abc123",
      confirm: "abc123"
    }.to_json)
    expect_raises(Exception) { k.parse!(json3) }
  end
end
