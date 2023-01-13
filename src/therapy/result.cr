abstract struct Therapy::Result(T)
  abstract def success? : Bool
  abstract def failure? : Bool
  abstract def value : T
  abstract def errors : Array(String)

  def map(&block : T -> Y) : Result(Y) forall Y
    if success?
      new_value = yield value
      Success(Y).new(new_value)
    else
      Failure(Y).new(errors)
    end
  end

  struct Success(T) < Result(T)
    getter value : T
    def initialize(@value)
    end

    def success? : Bool
      true
    end

    def failure? : Bool
      true
    end

    def errors : Array(String)
      [] of String
    end
  end
  struct Failure(T) < Result(T)
    getter errors : Array(String)
    def initialize(@errors)
    end

    def success? : Bool
      false
    end

    def failure? : Bool
      true
    end

    def value : T
      raise errors.join(", ")
    end
  end
end
