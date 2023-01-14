class Therapy::Int32Type < Therapy::BaseType(Int32)
  private getter checks = [] of Check(Int32)

  def parse(input : Int32) : Result(Int32)
    context = ParseContext(Int32).new(input)
    checks.each(&.check(context))

    context.to_result
  end

  def min(min : Int32) : self
    checks << Check(Int32).valid("Must be at least #{min}") { |i| i >= min }
    self
  end

  def max(max : Int32) : self
    checks << Check(Int32).valid("Must be at most #{max}") { |i| i <= max }
    self
  end

  protected def coerce(input : String) : Int32
    input.to_i32
  end

  protected def coerce(input : Bool) : Int32
    input ? 1 : 0
  end
end