class Therapy::BoolType < Therapy::BaseType(Bool)
  protected def coerce(input : String) : Bool
    case input.downcase
    when "true"
      true
    when "false"
      false
    else
      raise "can't handle this anymore #{input}"
    end
  end
end
