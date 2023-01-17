module Therapy
  abstract class BaseLiftedType(IN, T)
    abstract def parse!(input : IN) : T
    abstract def parse(input : IN) : Result(T)
  end

  class Therapy::LiftedType(IN, OUT, T) < BaseLiftedType(IN, T)
    private getter inner : BaseType(T)
    private getter fn : Proc(IN, OUT)

    def initialize(@inner, @fn)
    end

    def parse!(input : IN) : T
      parse(input).value
    end

    def parse(input : IN) : Result(T)
      inner.parse(fn.call(input))
    end
  end
end
