abstract class Therapy::BaseType(T)
  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def coercing : CoercingType(T)
    CoercingType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input : T) : Result(T)
    Result::Success.new(input)
  end

  def parse(input) : Result(T)
    Result::Failure(T).new(["can't parse this type"])
  end

  protected def coerce(input : T) : T
    input
  end

  protected abstract def coerce(input : _) : T
end