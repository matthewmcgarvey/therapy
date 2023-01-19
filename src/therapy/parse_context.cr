class Therapy::BaseParseContext(T, V)
  getter errors : Array(Therapy::Error)
  property value : V

  def initialize(@value, @errors = [] of Therapy::Error)
  end

  def add_error(msg : String)
    errors << Therapy::Error.new(msg)
  end

  def to_result : Result(T)
    if value.is_a?(T) && errors.empty?
      Result::Success(T).new(value.as(T))
    else
      Result::Failure(T).new(errors)
    end
  end

  def map(fn : V -> T) : ParseContext(T)
    ParseContext(T).new(fn.call(value), errors)
  end

  def map(fn : V -> X) : BaseParseContext(T, X) forall X
    ParseContext(T).create(fn.call(value), errors)
  end
end

class Therapy::ParseContext(T) < Therapy::BaseParseContext(T, T)
  def self.create(value : V, errors = [] of Therapy::Error) : BaseParseContext(T, V) forall V
    if value.is_a?(T)
      ParseContext(T).new(value, errors)
    else
      BaseParseContext(T, V).new(value, errors)
    end
  end
end
