abstract class Therapy::BaseType(T)
  @coercing : Bool = false
  private getter checks = [] of Check(T)

  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input : V) : Result(T) forall V
    context = coerce(ParseContext(T, V).new(input))
    _parse(context)
    context.to_result
  end

  def create_subcontext(parent : ParseContext, input : V, path) : ParseContext(T, V) forall V
    SubContext(T, V, typeof(parent)).new(parent, input, path).as(ParseContext(T, V))
  end

  def coercing : self
    @coercing = true
    self
  end

  protected def _parse(context : ParseContext(T, T)) : Nil
    checks.each(&.check(context))
  end

  protected def _parse(context) : Nil forall V
    # do nothing
  end

  protected def coerce(context : ParseContext(T, T)) : ParseContext(T, T)
    context
  end

  protected def coerce(context : ParseContext(T, V?)) : ParseContext(T, V?) | ParseContext(T, V) | ParseContext(T, T) forall V
    new_context = context.map_result do |val|
      if val.nil?
        Result::Failure(V).with_msg("Expected #{T} got nil")
      else
        Result::Success(V).new(val.not_nil!)
      end
    end
    if new_context.is_a?(ParseContext(T, V))
      do_the_thing(new_context)
    else
      new_context
    end
  end

  protected def coerce(context : ParseContext(T, V)) : ParseContext(T, V) | ParseContext(T, T) forall V
    do_the_thing(context)
  end

  protected def coerce(context : ParseContext)
    context.add_error("Something went wrong")
    context
  end

  private def do_the_thing(context : ParseContext(T, V)) : ParseContext(T, V) | ParseContext(T, T) forall V
    if @coercing
      _do_coerce(context)
    elsif context.value.is_a?(T)
      context.map(&.as(T))
    else
      context.add_error("Expected #{T} got #{context.value.class}")
      context
    end
  end

  protected def _do_coerce(context : ParseContext(T, V)) : ParseContext(T, V) | ParseContext(T, T) forall V
    context.map_result { |value| _coerce(value) }
  end

  protected def _coerce(value : T) : Result(T)
    Result::Success(T).new(value)
  end

  protected def _coerce(value : V) : Result(T) forall V
    Result::Failure(T).with_msg("_coerce: Expected #{T} got #{value.class}")
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
