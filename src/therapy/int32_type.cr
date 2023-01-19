class Therapy::Int32Type < Therapy::BaseType(Int32)
  def min(min : Int32) : self
    checks << Check(Int32).valid("Must be at least #{min}") { |i| i >= min }
    self
  end

  def max(max : Int32) : self
    checks << Check(Int32).valid("Must be at most #{max}") { |i| i <= max }
    self
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
