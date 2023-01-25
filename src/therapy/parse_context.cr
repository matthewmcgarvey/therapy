class Therapy::ParseContext(T, V)
  getter errors = [] of Therapy::Error
  property value : V

  def initialize(@value)
  end

  def add_error(msg : String)
    errors << Therapy::Error.new(msg, path: full_path)
  end

  def map(&block : V -> X) : ParseContext(T, X) forall X
    new_value = yield value
    ParseContext(T, X).new(new_value)
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

  def full_path : Array(String | Int32)
    [] of String | Int32
  end
end

class Therapy::SubContext(T, V, PARENT) < Therapy::ParseContext(T, V)
  private getter parent : PARENT
  property value : V
  property path : String | Symbol | Int32

  def initialize(@parent, @value, @path)
  end

  def full_path : Array(String | Int32)
    temp = path
    if temp.is_a?(Symbol)
      temp = temp.to_s
    end
    parent.full_path << temp
  end
end
