abstract class Therapy::BaseType(T)
  @coercing : Bool = false
  private getter checks = [] of Check(T)

  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input : T) : Result(T)
    context = ParseContext(T).new(input)
    checks.each(&.check(context))

    context.to_result
  end

  def parse(input) : Result(T)
    if input.nil?
      return Result::Failure(T).new(["input was nil and it shouldn't be"])
    end

    if @coercing
      parse(coerce(input))
    else
      Result::Failure(T).new(["can't parse this type"])
    end
  end

  protected def coerce(input : T) : T
    input
  end

  protected abstract def coerce(input : _) : T
end
