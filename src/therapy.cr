require "./therapy/result"
require "./therapy/parse_context"
require "./therapy/check"
require "./therapy/base_type"
require "./therapy/*"

module Therapy
  def self.string : StringType
    StringType.new
  end

  def self.int32 : Int32Type
    Int32Type.new
  end

  def self.bool : BoolType
    BoolType.new
  end

  def self.object(**options : **T) forall T
    {% begin %}
    ObjectType(T, {
      {% for key, type in T %}
        {% base_type = type.ancestors.find { |ancestor| ancestor <= Therapy::BaseType } %}
        {{key.id}}: {{ base_type.type_vars.first }},
      {% end %}
    }).new(options)
  {% end %}
  end

  def self.array(of validator : BaseType(T)) forall T
    ArrayType(T).new(validator)
  end

  def self.tuple(*options : *T) forall T
    {% begin %}
    TupleType(T, {
      {% for type in T %}
        {% base_type = type.ancestors.find { |ancestor| ancestor <= Therapy::BaseType } %}
        {{ base_type.type_vars.first }},
      {% end %}
    }).new(options)
  {% end %}
  end
end
