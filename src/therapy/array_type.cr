class Therapy::ArrayType(T) < Therapy::BaseType(Array(T))
  private getter validator : BaseType(T)

  def initialize(@validator)
  end

  protected def apply_checks(context : ParseContext(Array(T), Array(T))) : Nil
    checks.each(&.check(context))
    value = context.value
    value.each_with_index do |val, idx|
      new_path = context.full_path.dup
      new_path << idx
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  def coerce(value : V, path : Array(String | Int32) = [] of String | Int32) : Result(Array(T)) forall V
    coerce_value(value, path)
  end

  private def coerce_value(value : JSON::Any, path) : Result(Array(T))
    arr = value.as_a?
    return Result::Failure(Array(T)).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}", path) if arr.nil?
    coerce_elements(arr, path)
  end

  private def coerce_value(value : Array, path) : Result(Array(T))
    coerce_elements(value, path)
  end

  private def coerce_value(value, path) : Result(Array(T))
    Result::Failure(Array(T)).with_msg("Expected Array but got #{value.class}", path)
  end

  private def coerce_elements(arr, path) : Result(Array(T))
    all_errors = [] of Error
    values = [] of T

    arr.each_with_index do |val, idx|
      elem_path = path + [idx.as(String | Int32)]
      result = validator.coerce(val, elem_path)
      if result.failure?
        all_errors.concat(result.errors)
      else
        values << result.value
      end
    end

    if all_errors.any?
      Result::Failure(Array(T)).new(all_errors)
    else
      Result::Success(Array(T)).new(values)
    end
  end
end
