class Therapy::ParseContext(T)
  property value : T
  getter errors = [] of String

  def initialize(@value)
  end

  def to_result : Result(T)
    if errors.empty?
      Result::Success(T).new(value)
    else
      Result::Failure(T).new(errors)
    end
  end
end
