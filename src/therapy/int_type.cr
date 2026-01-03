class Therapy::IntType(INT) < Therapy::BaseType(INT)
  def min(min : INT) : self
    add_validation(
      ->(num : INT) { num >= min },
      "Must be at least #{min}"
    )
  end

  def max(max : INT) : self
    add_validation(
      ->(num : INT) { num <= max },
      "Must be at most #{max}"
    )
  end

  {% begin %}
  protected def _coerce(value : Int) : Result(INT)
    coerced = case INT
      {% for method, type in {
                               to_i8: Int8, to_i16: Int16, to_i32: Int32, to_i64: Int64, to_i128: Int128,
                               to_u8: UInt8, to_u16: UInt16, to_u32: UInt32, to_u64: UInt64, to_u128: UInt128,
                             } %}
      when {{ type }}.class
        value.{{ method }}
      {% end %}
      end
    Result::Success.new(coerced.as(INT))
  rescue OverflowError
    Result::Failure(INT).with_msg("Unable to coerce #{value.class} to #{INT}")
  end
  {% end %}

  protected def _coerce(value : JSON::Any) : Result(INT)
    _coerce(value.raw)
  end
end
