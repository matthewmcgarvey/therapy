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

  protected def _coerce(value : JSON::Any) : Result(T?)
    raw_val = value.raw
    if raw_val.nil?
      Result::Success(T?).new(nil)
    else
      inner._coerce(raw_val).map(&.as(T?))
    end
  end

  protected def _coerce(value : V?) : Result(T?) forall V
    if value.nil?
      Result::Success(T?).new(nil)
    else
      inner._coerce(value).map(&.as(T?))
    end
  end

  protected def apply_checks(context : ParseContext(T?, T?)) : Nil
    # TODO: compilation error
    # checks.each(&.check(context))
    value = context.value
    if value
      subcontext = inner.new_context(value, path: nil)
      inner.apply_checks(subcontext)
      context.errors.concat(subcontext.errors)
    end
  end
end
