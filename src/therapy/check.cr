class Therapy::Check(T)
  def self.valid(error_msg : String, &block : T -> Bool) : Check(T) forall T
    check = ->(input : ParseContext(T)) do
      if !block.call(input.value)
        input.errors << error_msg
      end
    end
    Check(T).new(check)
  end

  @check : ParseContext(T) -> Nil

  def initialize(@check)
  end

  def check(context : ParseContext(T))
    @check.call(context)
  end
end
