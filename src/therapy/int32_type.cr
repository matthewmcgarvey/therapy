class Therapy::Int32Type < Therapy::BaseType(Int32)
  def min(min : Int32) : self
    add_validation(
      ->(num : Int32) { num >= min },
      "Must be at least #{min}"
    )
  end

  def max(max : Int32) : self
    add_validation(
      ->(num : Int32) { num <= max },
      "Must be at most #{max}"
    )
  end

  protected def _coerce(value : String) : Result(Int32)
    if int = value.to_i32?
      Result::Success.new(int)
    else
      Result::Failure(Int32).with_msg("Can't turn String into Int32")
    end
  end

  protected def _coerce(value : Int64) : Result(Int32)
    Result::Success.new(value.to_i32!)
  end

  protected def _coerce(value : Bool) : Result(Int32)
    Result::Success.new(value ? 1 : 0)
  end

  protected def _coerce(value : JSON::Any) : Result(Int32)
    _coerce(value.raw)
  end
end
