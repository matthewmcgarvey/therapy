class Therapy::EnumType(ENUM) < Therapy::BaseType(ENUM)
  protected def _coerce(value : JSON::Any) : Result(ENUM)
    _coerce(value.raw)
  end

  protected def _coerce(value : String) : Result(ENUM)
    Result::Success.new(ENUM.parse(value))
  rescue ex : ArgumentError
    Result::Failure(ENUM).with_msg("Must be one of #{ENUM.values.join(", ")}")
  end

  protected def _coerce(value : Int) : Result(ENUM)
    Result::Success.new(ENUM.from_value(value))
  rescue ex : ArgumentError
    Result::Failure(ENUM).with_msg("Must be one of #{ENUM.values.map(&.value).join(", ")}")
  end
end
