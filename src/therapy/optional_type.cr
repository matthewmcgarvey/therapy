class Therapy::OptionalType(T) < Therapy::BaseType(T?)
  private getter inner : BaseType(T)

  def initialize(@inner : BaseType(T))
  end

  def optional : OptionalType(T)
    self
  end

  def parse(input : Nil) : Result(T?)
    Result::Success(T?).new(nil)
  end

  def coerce(value : V, path : Array(String | Int32) = [] of String | Int32) : Result(T?) forall V
    coerce_value(value, path)
  end

  private def coerce_value(value : JSON::Any, path) : Result(T?)
    raw_val = value.raw
    if raw_val.nil?
      Result::Success(T?).new(nil)
    else
      inner.coerce(raw_val, path).map(&.as(T?))
    end
  end

  private def coerce_value(value : Nil, path) : Result(T?)
    Result::Success(T?).new(nil)
  end

  private def coerce_value(value, path) : Result(T?)
    inner.coerce(value, path).map(&.as(T?))
  end

  protected def apply_checks(context : ParseContext(T?, T?)) : Nil
    # TODO: compilation error
    # checks.each(&.check(context))
    value = context.value
    if value
      inner.apply_checks_on_coerced(value, context.full_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end
end
