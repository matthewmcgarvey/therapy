abstract class Therapy::BaseType(T)
  protected getter checks = [] of Check(T)

  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def parse!(input) : T
    parse(input).value
  end

  def parse(input : V) : Result(T) forall V
    create_context(input, [] of String | Int32).parse
  end

  # Creates a parse context - override in container types to include subcontexts
  def create_context(value : V, path : Array(String | Int32)) : ParseContext(T, V) forall V
    ParseContext(T, V).new(value, self, path)
  end

  protected def apply_checks(context : ParseContext(T, T)) : Nil
    checks.each(&.check(context))
  end

  protected def apply_checks(context) : Nil
    # do nothing, coercing failed
  end

  # Runs apply_checks on an already-coerced value, returning any errors
  def apply_checks_on_coerced(value, path : Array(String | Int32) = [] of String | Int32) : Array(Error)
    context = ParseContext(T, T).new(value.as(T), self, path)
    apply_checks(context)
    context.errors
  end

  # Coerce the value, using subcontext results for container types
  def coerce(context : ParseContext(T, V)) : Result(T) forall V
    result = _coerce(context.value)
    if result.failure? && result.errors.any?(&.path.empty?)
      # Add path to errors that don't have one
      errors = result.errors.map do |err|
        err.path.empty? ? Error.new(err.message, context.full_path) : err
      end
      Result::Failure(T).new(errors)
    else
      result
    end
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

  private def add_validation(validation : T -> Bool, err_msg : String, path : Array(String | Int32)? = nil) : self
    checks << Check(T).valid(err_msg, path, &validation)
    self
  end
end
