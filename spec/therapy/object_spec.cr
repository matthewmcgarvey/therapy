require "../spec_helper"

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
    validation = Therapy.object(id: Therapy.int32, roles: Therapy.array(Therapy.string).optional)
    # validation.parse!(json_attr_missing).should eq({id: 123, roles: nil})
    validation.parse!(json_attr_null).should eq({id: 123, roles: nil})
  end
end
