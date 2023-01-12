abstract class Therapy::Validated(ERR, VAL)
  def fold(ferr : ERR -> T, fval : VAL -> T) : T forall T
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
    fold(->(_val : ERR) { false }, ->(_val : VAL) { true })
  end

  def invalid? : Bool
    fold(->(_val : ERR) { true }, ->(_val : VAL) { false })
  end

  def map(&block : VAL -> NEWVAL) : Validated(ERR, NEWVAL) forall NEWVAL
    flat_map do |input|
      Valid(ERR, NEWVAL).new(block.call(input))
    end
  end

  def flat_map(&block : VAL -> Validated(ERR, NEWVAL)) : Validated(ERR, NEWVAL) forall NEWVAL
    case self
    when Valid
      block.call(self.value)
    when Invalid
      Invalid(ERR, NEWVAL).new(self.value)
    else
      raise "crystal... why?"
    end
  end

  def handle_err_with(&block : ERR -> Validated(ERR, VAL)) : Validated(ERR, VAL)
    case self
    when Valid
      self
    when Invalid
      block.call(self.value)
    else
      raise "crystal... why?"
    end
  end

  def or_else(&block : -> Validated(ERR, VAL)) : Validated(ERR, VAL)
    handle_err_with { |_input| block.call }
  end

  def redeem(ferr : ERR -> NEWVAL, fval : VAL -> NEWVAL) : Validated(ERR, NEWVAL) forall NEWVAL
    case self
    when Valid
      map(&fval)
    when Invalid
      Valid(ERR, NEWVAL).new(ferr.call(self.value))
    else
      raise "crystal... why?"
    end
  end

  class Invalid(ERR, VAL) < Validated(ERR, VAL)
    getter value : ERR

    def initialize(@value : ERR)
    end
  end

  class Valid(ERR, VAL) < Validated(ERR, VAL)
    getter value : VAL

    def initialize(@value : VAL)
    end
  end
end
