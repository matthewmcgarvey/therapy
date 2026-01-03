class Therapy::ObjectType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def validate(err_msg : String, &validation : OUT -> Bool) : self
    add_validation(validation, err_msg)
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.each do |key, validator|
      val = value[key]
      subcontext = validator.create_subcontext(context, val, path: key)
      validator.apply_checks(subcontext)
      subcontext.errors.each(&.path.push(key.to_s))
      context.errors.concat(subcontext.errors)
    end
  end

  protected def _coerce(value : JSON::Any) : Result(OUT)
    hash = value.as_h?
    return Result::Failure(OUT).with_msg("Expected JSON to be a Hash but it was a #{value.raw.class}") if hash.nil?

    coercing_each do |key, validator|
      val = hash[key.to_s]?
      {key, validator._coerce(val)}
    end
  end

  protected def _coerce(value : URI::Params) : Result(OUT)
    coercing_each do |key, validator|
      val = if validator.is_a?(ArrayType)
              value.fetch_all(key.to_s)
            else
              value[key.to_s]?
            end
      {key, validator._coerce(val)}
    end
  end

  protected def _coerce(value : Hash(String, V)) : Result(OUT) forall V
    coercing_each do |key, validator|
      val = value[key.to_s]?
      {key, validator._coerce(val)}
    end
  end

  protected def _coerce(value : NamedTuple) : Result(OUT)
    coercing_each do |key, validator|
      val = value[key]?
      {key, validator._coerce(val)}
    end
  end

  private def coercing_each(&) : Result(OUT)
    results = validators.map do |key, validator|
      yield key, validator
    end

    # TODO: errors should probably have the path set on them
    if results.any? { |res| res[1].failure? }
      errors = results.flat_map { |res| res[1].errors }
      return Result::Failure(OUT).new(errors)
    end

    hash = results.map { |res| {res[0], res[1].value} }.to_h
    Result::Success(OUT).new(OUT.from(hash))
  end
end
