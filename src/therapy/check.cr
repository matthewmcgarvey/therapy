class Therapy::Check(T)
  def self.valid(error_msg : String, &block : T -> Bool) : Check(T) forall T
    check = ->(input : Therapy::ParseContext(T, T)) do
      if !block.call(input.value)
        err = Therapy::Error.new(error_msg)
        input.errors << err
      end
    end
    Check(T).new(check)
  end

  @check : Therapy::ParseContext(T, T) -> Nil

  def initialize(@check)
  end

  def check(context : Therapy::ParseContext(T, T))
    @check.call(context)
  end
end
