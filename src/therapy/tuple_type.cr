class Therapy::TupleType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.map_with_index do |validator, idx|
      val = value[idx]
      new_path = context.full_path.dup
      new_path << idx
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  def coerce(value : V, path : Array(String | Int32) = [] of String | Int32) : Result(OUT) forall V
    coerce_value(value, path)
  end

  private def coerce_value(value : JSON::Any, path) : Result(OUT)
    arr = value.as_a?
    return Result::Failure(OUT).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}", path) if arr.nil?
    coerce_elements(arr, path)
  end

  private def coerce_value(value : Array, path) : Result(OUT)
    coerce_elements(value, path)
  end

  private def coerce_value(value, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected Array but got #{value.class}", path)
  end

  private def coerce_elements(arr, path) : Result(OUT)
    if arr.size != validators.size
      return Result::Failure(OUT).with_msg("Must have size of #{validators.size} but was #{arr.size}", path)
    end

    all_errors = [] of Error
    results = validators.map_with_index do |validator, idx|
      val = arr[idx]?
      elem_path = path + [idx.as(String | Int32)]
      result = validator.coerce(val, elem_path)
      all_errors.concat(result.errors) if result.failure?
      result
    end

    return Result::Failure(OUT).new(all_errors) if all_errors.any?

    result_arr = results.map(&.value).to_a
    Result::Success(OUT).new(OUT.from(result_arr))
  end
end
