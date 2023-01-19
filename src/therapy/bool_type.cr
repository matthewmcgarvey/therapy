class Therapy::BoolType < Therapy::BaseType(Bool)
  def coercing : self
    @coercing = true
    self
  end

  protected def coerce(value : String) : Result(Bool)
    case value.downcase
    when "true"
      Result::Success.new(true)
    when "false"
      Result::Success.new(false)
    else
      Result::Failure(Bool).with_msg("Not coercable to bool")
    end
  end
end
