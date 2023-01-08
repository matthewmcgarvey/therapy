abstract class Therapy::Validated(VAL)
  def fold(ferr : String -> T, fval : VAL -> T) : T forall T
    case self
    when Valid
      fval.call(self.value)
    when Invalid
      ferr.call(self.value)
    else
      raise "crystal... why?"
    end
  end

  def valid? : Bool
    fold(->(_val : String) { false }, ->(_val : VAL) { true })
  end

  def invalid? : Bool
    fold(->(_val : String) { true }, ->(_val : VAL) { false })
  end

  def map(&block : VAL -> NEWVAL) : Validated(NEWVAL) forall NEWVAL
    flat_map do |input|
      Valid.new(block.call(input))
    end
  end

  def flat_map(&block : VAL -> Validated(NEWVAL)) : Validated(NEWVAL) forall NEWVAL
    case self
    when Valid
      block.call(self.value)
    when Invalid
      Invalid(NEWVAL).new(self.value)
    else
      raise "crystal... why?"
    end
  end

  def handle_err_with(&block : String -> Validated(VAL)) : Validated(VAL)
    case self
    when Valid
      self
    when Invalid
      block.call(self.value)
    else
      raise "crystal... why?"
    end
  end

  def or_else(&block : -> Validated(VAL)) : Validated(VAL)
    handle_err_with { |_input| block.call }
  end

  def redeem(ferr : String -> NEWVAL, fval : VAL -> NEWVAL) : Validated(NEWVAL) forall NEWVAL
    case self
    when Valid
      map(&fval)
    when Invalid
      Valid.new(ferr.call(self.value))
    else
      raise "crystal... why?"
    end
  end

  class Invalid(VAL) < Validated(VAL)
    getter value : String

    def initialize(@value : String)
    end
  end

  class Valid(VAL) < Validated(VAL)
    getter value : VAL

    def initialize(@value : VAL)
    end
  end
end
