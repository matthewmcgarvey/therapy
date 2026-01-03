class Therapy::BoolType < Therapy::BaseType(Bool)
  protected def _coerce(value : String) : Result(Bool)
    case value.downcase
    when "true"
      Result::Success.new(true)
    when "false"
      Result::Success.new(false)
    else
      Result::Failure(Bool).with_msg("Not coercable to bool")
    end
  end

  protected def _coerce(value : JSON::Any) : Result(Bool)
    _coerce(value.raw)
  end
end
