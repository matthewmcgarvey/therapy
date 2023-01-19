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
    context = coerce(context) if @coercing
    _parse(context)
  end

  protected def _parse(context : ParseContext(T)) : Result(T)
    checks.each(&.check(context))

    context.to_result
  end

  protected def _parse(context : BaseParseContext(T, V)) : Result(T) forall V
    context.add_error("Input was #{V} and expected it to be #{T}")
    context.to_result
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

  protected def coerce(context : BaseParseContext(T, V)) : ParseContext(T) forall V
    context.map ->(input : V) { _coerce(input) }
  end

  protected def _coerce(value : T) : T
    value
  end

  protected abstract def _coerce(value : _) : T
end
