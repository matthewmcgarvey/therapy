class Therapy::TupleType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.map_with_index do |validator, idx|
      val = value[idx]
      subcontext = validator.create_subcontext(context, val, path: idx)
      validator.apply_checks(subcontext)
      subcontext.errors.each(&.path.push(idx))
      context.errors.concat(subcontext.errors)
    end
  end

  protected def _coerce(value : Array) : Result(OUT)
    coercing_each do |key, validator|
      val = value[key]?
      {key, validator._coerce(val)}
    end
  end

  protected def _coerce(value : JSON::Any) : Result(OUT)
    arr = value.as_a?
    return Result::Failure(OUT).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}") if arr.nil?

    coercing_each do |key, validator|
      val = arr[key]?
      {key, validator._coerce(val)}
    end
  end

  private def coercing_each(&) : Result(OUT)
    results = validators.map_with_index do |validator, idx|
      yield idx, validator
    end

    if results.any? { |res| res[1].failure? }
      errors = results.flat_map { |res| res[1].errors }
      return Result::Failure(OUT).new(errors)
    end

    arr = results.map { |res| res[1].value }.to_a
    Result::Success(OUT).new(OUT.from(arr))
  end
end
