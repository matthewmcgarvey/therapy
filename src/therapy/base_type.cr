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
    if input.nil?
      return Result::Failure(T).new([Therapy::Error.new("Input was nil and expected it to be #{T}")])
    end

    context = ParseContext(T).create(input)
    parse_context(context)
  end

  protected def parse_context(context : BaseParseContext(T, V)) : Result(T) forall V
    if @coercing
      coerced = coerce(context.value)
      return coerced if coerced.failure?

      context = ParseContext(T).create(coerced.value)
    end
    _parse(context)
    context.to_result
  end

  protected def _parse(context : ParseContext(T)) : Nil
    checks.each(&.check(context))
  end

  protected def _parse(context : BaseParseContext(T, V)) : Nil forall V
    context.add_error("Input was #{V} and expected it to be #{T}")
  end

  def from_json(&block : JSON::Any -> OUT) : LiftedType(JSON::Any, OUT, T) forall OUT
    lift(block)
  end

  def from_params(&block : URI::Params -> OUT) : LiftedType(URI::Params, OUT, T) forall OUT
    lift(block)
  end

  def lift(fn : Proc(IN, OUT)) : LiftedType(IN, OUT, T) forall IN, OUT
    Therapy::LiftedType(IN, OUT, T).new(self, fn)
  end

  protected def coerce(value : T) : Result(T)
    Result::Success(T).new(value)
  end

  protected abstract def coerce(value : _) : Result(T)

  private def add_check(check : ParseContext(T) ->)
    checks << Check(T).new(check)
    self
  end

  private def add_validation(validation : T -> Bool, err_msg : String) : self
    checks << Check(T).valid(err_msg, &validation)
    self
  end
end
