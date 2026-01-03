class Therapy::ArrayType(T) < Therapy::BaseType(Array(T))
  private getter validator : BaseType(T)

  def initialize(@validator)
  end

  protected def apply_checks(context : ParseContext(Array(T), Array(T))) : Nil
    checks.each(&.check(context))
    value = context.value
    value.each_with_index do |val, idx|
      subcontext = validator.create_subcontext(context, val, path: idx)
      validator.apply_checks(subcontext)
      subcontext.errors.each(&.path.push(idx))
      context.errors.concat(subcontext.errors)
    end
  end

  protected def _coerce(value : JSON::Any) : Result(Array(T))
    arr = value.as_a?
    return Result::Failure(Array(T)).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}") if arr.nil?

    results = arr.map_with_index do |val, idx|
      {idx, validator._coerce(val)}
    end

    handle_coerce_results(results)
  end

  protected def _coerce(value : Array) : Result(Array(T))
    results = value.map_with_index do |val, idx|
      {idx, validator._coerce(val)}
    end

    handle_coerce_results(results)
  end

  private def handle_coerce_results(results : Array(Tuple(Int32, Result(T)))) : Result(Array(T))
    # TODO: errors should probably have the path set to the idx value
    if results.any? { |res| res[1].failure? }
      errors = results.flat_map { |res| res[1].errors }
      return Result::Failure(Array(T)).new(errors)
    end

    result_arr = results.map { |res| res[1].value.as(T) }
    Result::Success(Array(T)).new(result_arr)
  end
end
