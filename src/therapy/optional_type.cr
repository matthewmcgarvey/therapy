class Therapy::OptionalType(T) < Therapy::BaseType(T?)
  private getter inner : BaseType(T)

  def initialize(@inner : BaseType(T))
  end

  def optional : OptionalType(T)
    self
  end

  def parse(input) : Result(T?)
    if input.nil?
      Result::Success(T?).new(nil)
    else
      inner.parse(input).map(&.as(T?))
    end
  end

  def _coerce(value) : Result(T?)
    return Result::Success(T?).new(nil) if value.nil?

    inner.coerce(value)
  end
end
