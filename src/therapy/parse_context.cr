class Therapy::ParseContext(T, V)
  getter errors = [] of Therapy::Error
  getter full_path : Array(String | Int32)
  property value : V

  def initialize(@value)
    @full_path = [] of String | Int32
  end

  def add_error(msg : String, path : Array(String | Int32)? = nil)
    errors << Therapy::Error.new(msg, path: path || full_path)
  end

  def map_result(&block : V -> Result(X)) : ParseContext(T, V) | ParseContext(T, X) forall X
    result = yield value
    if result.failure?
      errors.concat(result.errors)
      self
    else
      ParseContext(T, X).new(result.value)
    end
  end

  def to_result : Result(T)
    if value.is_a?(T) && errors.empty?
      Result::Success(T).new(value.as(T))
    else
      Result::Failure(T).new(errors)
    end
  end
end
