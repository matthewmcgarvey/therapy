abstract class Therapy::BaseType(T)
  @coercing : Bool = false
  private getter checks = [] of Check(T)

  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input) : Result(T)
    coerced = do_coerce(input)
    return coerced if coerced.failure?

    context = ParseContext(T).create(coerced.value)
    _parse(context)
    context.to_result
  end

  def create_parse_context(input : V) : BaseParseContext(T, V) forall V
    ParseContext(T).create(input)
  end

  def coercing : self
    @coercing = true
    self
  end

  protected def _parse(context : ParseContext(T)) : Nil
    checks.each(&.check(context))
  end

  protected def _parse(context : BaseParseContext(T, V)) : Nil forall V
    context.add_error("Input was #{V} and expected it to be #{T}")
  end

  protected def do_coerce(value : T) : Result(T)
    Result::Success(T).new(value)
  end

  protected def do_coerce(value) : Result(T)
    if @coercing
      coerce(value)
    else
      Result::Failure(T).with_msg("Expected #{T} got #{value.class}")
    end
  end

  protected def coerce(value : T) : Result(T)
    Result::Success(T).new(value)
  end

  protected def coerce(value) : Result(T)
    Result::Failure(T).with_msg("Expected #{T} got #{value.class}")
  end


  private def add_check(check : ParseContext(T) ->)
    checks << Check(T).new(check)
    self
  end

  private def add_validation(validation : T -> Bool, err_msg : String) : self
    checks << Check(T).valid(err_msg, &validation)
    self
  end
end
