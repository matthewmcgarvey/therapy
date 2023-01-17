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
    {% for key, type in T %}
      {% if type.name(generic_args: false) != "Therapy::LiftedType".id %}
        {% raise "Expected #{key}: #{type} to be a Therapy::LiftedType but it was not" %}
      {% end %}
    {% end %}
    {% in_type = T[T.keys.first].type_vars[0] %}
    ObjectType({{ in_type }}, T, {
      {% for key, type in T %}
        {{key.id}}: {{ type.type_vars[2] }},
      {% end %}
    }).new(options)
  {% end %}
  end
end
