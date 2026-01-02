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

  protected def _coerce(value : Int64) : Result(Int32)
    Result::Success.new(value.to_i32)
  rescue OverflowError
    Result::Failure(Int32).with_msg("Unable to coerce Int64 to Int32")
  end

  protected def _coerce(value : JSON::Any) : Result(Int32)
    _coerce(value.raw)
  end
end
