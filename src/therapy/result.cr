abstract struct Therapy::Result(T)
  abstract def success? : Bool
  abstract def failure? : Bool
  abstract def value : T
  abstract def errors : Array(Therapy::Error)

  def valid? : Bool
    success?
  end

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
      false
    end

    def errors : Array(Therapy::Error)
      [] of Therapy::Error
    end
  end

  struct Failure(T) < Result(T)
    def self.with_msg(err_msg : String) : Failure(T)
      new([Therapy::Error.new(err_msg)])
    end

    getter errors : Array(Therapy::Error)

    def initialize(@errors)
    end

    def success? : Bool
      false
    end

    def failure? : Bool
      true
    end

    def value : T
      raise errors.map(&.to_s).join(", ")
    end
  end
end
