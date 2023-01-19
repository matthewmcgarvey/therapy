class Therapy::ObjectType(IN, VALIDATORS, OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def parse(input : IN) : Result(OUT)
    results = validators.map do |key, validator|
      {key, validator.parse(input)}
    end

    if results.all? { |res| res[1].success? }
      hash = results.map { |res| {res[0], res[1].value} }.to_h
      Result::Success.new(OUT.from(hash))
    else
      errors = results.flat_map { |res| res[1].errors.map { |err| Therapy::Error.new("#{res[0]}: #{err}") } }
      Result::Failure(OUT).new(errors)
    end
  end

  def parse!(input : IN) : OUT
    parse(input).value
  end
end
