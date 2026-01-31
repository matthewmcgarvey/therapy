class Therapy::ObjectType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def validate(err_msg : String, path : Array(String | Int32)? = nil, &validation : OUT -> Bool) : self
    add_validation(validation, err_msg, path.try(&.map(&.as(String | Int32))))
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.each do |key, validator|
      val = value[key]
      new_path = context.full_path.dup
      new_path << key.to_s
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  def coerce(value : V, path : Array(String | Int32) = [] of String | Int32) : Result(OUT) forall V
    coerce_value(value, path)
  end

  private def coerce_value(value : JSON::Any, path) : Result(OUT)
    hash = value.as_h?
    return Result::Failure(OUT).with_msg("Expected JSON to be a Hash but it was a #{value.raw.class}", path) if hash.nil?
    coerce_fields(path) { |key| hash[key.to_s]? }
  end

  private def coerce_value(value : URI::Params, path) : Result(OUT)
    coerce_fields(path) do |key, validator|
      if validator.is_a?(ArrayType) || validator.is_a?(TupleType)
        value.fetch_all(key.to_s)
      else
        value[key.to_s]?
      end
    end
  end

  private def coerce_value(value : Hash, path) : Result(OUT)
    coerce_fields(path) { |key| value[key.to_s]? }
  end

  private def coerce_value(value : NamedTuple, path) : Result(OUT)
    coerce_fields(path) { |key| value[key]? }
  end

  private def coerce_value(value, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected Hash-like input but go #{value.class}", path)
  end

  private def coerce_fields(path, &get_value) : Result(OUT)
    all_errors = [] of Error
    results = validators.map do |key, validator|
      val = yield key, validator
      field_path = path + [key.to_s.as(String | Int32)]
      result = validator.coerce(val, field_path)
      all_errors.concat(result.errors) if result.failure?
      {key, result}
    end

    return Result::Failure(OUT).new(all_errors) if all_errors.any?

    hash = results.map { |key, res| {key, res.value} }.to_h
    Result::Success(OUT).new(OUT.from(hash))
  end
end
