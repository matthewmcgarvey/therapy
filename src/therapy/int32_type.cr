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

  def coercing : self
    @coercing = true
    self
  end

  protected def _coerce(value : String) : Int32
    value.to_i32
  end

  protected def _coerce(value : Bool) : Int32
    value ? 1 : 0
  end
end
