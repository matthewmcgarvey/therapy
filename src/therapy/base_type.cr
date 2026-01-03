abstract class Therapy::BaseType(T)
  protected getter checks = [] of Check(T)

  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input : V) : Result(T) forall V
    _parse(ParseContext(T, V).new(input))
  end

  def create_subcontext(parent : ParseContext, input : V, path : PathType) : ParseContext(T, V) forall V
    SubContext(T, V, typeof(parent)).new(parent, input, path).as(ParseContext(T, V))
  end

  protected def _parse(context : ParseContext(T, V)) : Result(T) forall V
    context = coerce(context)
    apply_checks(context)
    context.to_result
  end

  protected def apply_checks(context : ParseContext(T, T)) : Nil
    checks.each(&.check(context))
  end

  protected def apply_checks(context) : Nil
    # do nothing, coercing failed
  end

  protected def coerce(context : ParseContext(T, V)) : ParseContext(T, V) | ParseContext(T, T) forall V
    context.map_result { |value| _coerce(value) }
  end

  protected def coerce(context : ParseContext)
    context.add_error("Something went wrong")
    context
  end

  protected def _coerce(value : T) : Result(T)
    Result::Success(T).new(value)
  end

  protected def _coerce(value : V) : Result(T) forall V
    Result::Failure(T).with_msg("Expected #{T} got #{value.class}")
  end

  private def add_check(&check : ParseContext(T, T) -> Nil) : self
    checks << Check(T).new(check)
    self
  end

  private def add_validation(validation : T -> Bool, err_msg : String) : self
    checks << Check(T).valid(err_msg, &validation)
    self
  end
end
