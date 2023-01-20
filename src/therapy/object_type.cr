class Therapy::ObjectType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def _parse(input : ParseContext(OUT)) : Result(OUT)
    with_handling do |key, validator|
      sub_input = input.value[key]
      sub_parse_context = validator.create_parse_context(sub_input)
      validator._parse(sub_parse_context)
      {key, sub_parse_context.to_result}
    end
  end

  def coerce(value : NamedTuple) : Result(OUT)
    handle_coercion do |key|
      value[key]?
    end
  end

  def coerce(value : JSON::Any) : Result(OUT)
    handle_coercion do |key|
      value[key.to_s]?.try(&.raw)
    end
  end

  def coerce(value : URI::Params) : Result(OUT)
    handle_coercion do |key|
      value[key.to_s]?
    end
  end

  def coerce(value : Hash) : Result(OUT)
    handle_coercion do |key|
      value[key]? || value[key.to_s]?
    end
  end

  private def handle_coercion
    with_handling do |key, validator|
      sub_input = yield key
      {key, validator.do_coerce(sub_input)}
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
      errors = results.flat_map { |res| res[1].errors.map { |err| Therapy::Error.new("#{res[0]}: #{err.message}") } }
      Result::Failure(OUT).new(errors)
    end
  end
end
