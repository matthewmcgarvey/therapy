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

  # Value is nil
  protected def coerce(context : ParseContext(T?, Nil)) : ParseContext(T?, T?)
    context.map_result do |val|
      Result::Success(T?).new(val)
    end
  end

  # Need to pull out raw value for coercing
  protected def coerce(context : ParseContext(T?, JSON::Any?))
    coerce(context.map(&.try(&.raw)))
  end

  # Pass non-nil value to inner validator
  protected def coerce(context : ParseContext(T?, V)) forall V
    context.map_result do |val|
      if val.nil?
        Result::Success(T?).new(val)
      else
        subcontext = inner.create_subcontext(context, val, 0)
        subcontext = inner.coerce(subcontext)
        inner._parse(subcontext)
        subcontext.to_result.map(&.as(T?))
      end
    end
  end
end
