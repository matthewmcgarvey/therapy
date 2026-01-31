class Therapy::ParseContext(T, V)
  getter errors = [] of Therapy::Error
  getter full_path : Array(String | Int32)
  property value : V
  protected getter type : BaseType(T)

  def initialize(@value, @type, @full_path = [] of String | Int32)
  end

  def parse : Result(T)
    result = type.coerce(value, full_path)
    return result if result.failure?

    # Coercion succeeded, run checks (which may transform the value)
    context = ParseContext(T, T).new(result.value, type, full_path)
    type.apply_checks(context)
    if context.errors.any?
      Result::Failure(T).new(context.errors)
    else
      # Return context.value in case checks modified it
      Result::Success(T).new(context.value)
    end
  end

  def add_error(msg : String, path : Array(String | Int32)? = nil)
    errors << Therapy::Error.new(msg, path: path || full_path)
  end
end
