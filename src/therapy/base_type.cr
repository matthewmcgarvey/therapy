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

  def from_json(&block : JSON::Any -> OUT) : LiftedType(JSON::Any, OUT, T) forall OUT
    lift(block)
  end

  def from_params(&block : URI::Params -> OUT) : LiftedType(URI::Params, OUT, T) forall OUT
    lift(block)
  end

  def lift(fn : Proc(IN, OUT)) : LiftedType(IN, OUT, T) forall IN, OUT
    Therapy::LiftedType(IN, OUT, T).new(self, fn)
  end

  protected def coerce(input : T) : T
    input
  end

  protected abstract def coerce(input : _) : T
end
