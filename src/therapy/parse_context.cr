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

end

class Therapy::ParseContext(T) < Therapy::BaseParseContext(T, T)
  def self.create(value : T) : ParseContext(T)
    new(value)
  end

  def self.create(value : V) : BaseParseContext(T, V) forall V
    BaseParseContext(T, V).new(value)
  end
end
