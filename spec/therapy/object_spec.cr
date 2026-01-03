require "../spec_helper"
require "../support/enums"

describe Therapy::ObjectType do
  it "is invalid if attribute is invalid" do
    validation = Therapy.object(password: Therapy.string.min(5))
    validation.parse({"password" => "abc"}).should be_error("[\"password\"]: Must have minimum size of 5")
  end

  it "handles array attribute from json" do
    json = JSON.parse(<<-JSON)
      {
        "roles": ["admin", "user"]
      }
    JSON
    validation = Therapy.object(roles: Therapy.array(Therapy.string))
    validation.parse!(json).should eq({roles: ["admin", "user"]})
  end

  it "handles optional array attribute from json" do
    json_attr_missing = JSON.parse("{\"id\": 123}")
    json_attr_null = JSON.parse(<<-JSON)
      {
        "id": 123,
        "roles": null
      }
    JSON
    validation = Therapy.object(id: Therapy.int, roles: Therapy.array(Therapy.string).optional)
    validation.parse!(json_attr_missing).should eq({id: 123, roles: nil})
    validation.parse!(json_attr_null).should eq({id: 123, roles: nil})
  end

  it "handles coercing bool attribute from string" do
    validation = Therapy.object(key: Therapy.bool)

    validation.parse!({key: "true"}).should eq({key: true})
  end

  it "ignores extra attributes on input" do
    validation = Therapy.object(key: Therapy.string)

    validation.parse!({key: "foo", other: 123}).should eq({key: "foo"})
  end

  context "URI::Params" do
    it "single value" do
      params = URI::Params.new({"admin" => ["true"]})
      validation = Therapy.object(admin: Therapy.bool)

      validation.parse!(params).should eq({admin: true})
    end

    it "array value" do
      params = URI::Params.new({"colors" => ["red", "blue"]})
      validation = Therapy.object(colors: Therapy.array(Therapy.string))

      validation.parse!(params).should eq({colors: ["red", "blue"]})
    end

    it "array value as tuple" do
      params = URI::Params.new({"colors" => ["red", "blue"]})
      validation = Therapy.object(colors: Therapy.tuple(Therapy.string, Therapy.string))

      validation.parse!(params).should eq({colors: {"red", "blue"}})
    end
  end

  it "does not mess up validations if more than one attribute is invalid" do
    validation = Therapy.object(
      first_name: Therapy.string.min(3),
      last_name: Therapy.string.min(3)
    )

    validation.parse({first_name: "a", last_name: "b"})
      .should be_error(%{["first_name"]: Must have minimum size of 3, ["last_name"]: Must have minimum size of 3})
  end

  describe "#validate" do
    it "works" do
      validation = Therapy.object(
        pw: Therapy.string,
        pw_confirmation: Therapy.string
      ).validate("Confirmation must match pw") do |val|
        val[:pw] == val[:pw_confirmation]
      end

      validation.parse!({"pw" => "abc123", "pw_confirmation" => "abc123"})
        .should eq({pw: "abc123", pw_confirmation: "abc123"})
      validation.parse({"pw" => "abc123", "pw_confirmation" => "def456"})
        .should be_error("Confirmation must match pw")
    end
  end

  it "works with enums" do
    validation = Therapy.object(
      name: Therapy.string,
      role: Therapy.enum(Role)
    )

    validation.parse!({"name" => "hackerman", "role" => "admin"}).should eq({name: "hackerman", role: Role::Admin})
  end
end
