class Therapy::ObjectType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def validate(err_msg : String, &validation : OUT -> Bool) : self
    add_validation(validation, err_msg)
  end

  def _parse(input : ParseContext(OUT, OUT)) : Result(OUT)
    with_parse_handling(input) do |key, validator|
      value = input.value[key]
      sub_parse_context = validator.create_subcontext(input, value, path: key)
      validator._parse(sub_parse_context)
      {key, sub_parse_context.to_result}
    end
  end

  def _do_coerce(context : ParseContext(OUT, NamedTuple))
    context.map_result do |value|
      handle_coercion(context) do |key|
        value[key]?
      end
    end
  end

  def _do_coerce(context : ParseContext(OUT, JSON::Any))
    context.map_result do |value|
      handle_coercion(context) do |key|
        value[key.to_s]?
      end
    end
  end

  def _do_coerce(context : ParseContext(OUT, URI::Params))
    context.map_result do |value|
      handle_coercion(context) do |key|
        value[key.to_s]?
      end
    end
  end

  def _do_coerce(context : ParseContext(OUT, Hash))
    context.map_result do |value|
      handle_coercion(context) do |key|
        value[key]? || value[key.to_s]?
      end
    end
  end

  private def handle_coercion(context)
    with_handling do |key, validator|
      value = yield key
      sub_context = validator.create_subcontext(context, value, path: key)
      {key, validator.coerce(sub_context).to_result}
    end
  end

  private def with_parse_handling(context)
    results = validators.map do |key, validator|
      yield key, validator
    end

    checks.each(&.check(context))

    if results.all? { |res| res[1].success? } && context.errors.none?
      hash = results.map { |res| {res[0], res[1].value} }.to_h
      Result::Success(OUT).new(OUT.from(hash))
    else
      field_errors = results.flat_map { |res| res[1].errors }
      object_errors = context.errors
      Result::Failure(OUT).new(field_errors + object_errors)
    end
  end

  private def with_handling
    results = validators.map do |key, validator|
      yield key, validator
    end

    if results.all? { |res| res[1].success? }
      hash = results.map { |res| {res[0], res[1].value} }.to_h
      Result::Success(OUT).new(OUT.from(hash))
    else
      errors = results.flat_map { |res| res[1].errors }
      Result::Failure(OUT).new(errors)
    end
  end
end
