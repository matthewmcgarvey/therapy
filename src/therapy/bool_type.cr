class Therapy::BoolType < Therapy::BaseType(Bool)
  def coercing : self
    @coercing = true
    self
  end

  protected def _coerce(value : String) : Bool
    case value.downcase
    when "true"
      true
    when "false"
      false
    else
      raise "can't handle this anymore #{value}"
    end
  end
end
