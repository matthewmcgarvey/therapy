class Therapy::FloatType(FLOAT) < Therapy::BaseType(FLOAT)
  protected def _coerce(value : Float) : Result(FLOAT)
    coerced = case FLOAT
              when Float32.class
                value.to_f32
              when Float64.class
                value.to_f64
              end
    Result::Success.new(coerced.as(FLOAT))
  rescue OverflowError
    Result::Failure(FLOAT).with_msg("Unable to coerce #{value.class} to #{FLOAT}")
  end

  protected def _coerce(value : JSON::Any) : Result(FLOAT)
    _coerce(value.raw)
  end
end
