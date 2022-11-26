require "./therapy/validation"

# TODO: Write documentation for `Therapy`
class Therapy(T)
  VERSION = "0.1.0"

  def self.for(type : T.class) : Therapy(T) forall T
    new(type) { |input| Validation::Valid.new(input) }
  end

  def self.compose(*validators : Therapy(T)) : Therapy(T) forall T
    new(T) do |input|
      Validation.compose(*validators.map(&.validate(input)))
    end
  end

  private getter proc : Proc(T, Validation(T))

  def initialize(input_type : T.class, &block : T -> Validation(T))
    @proc = block
  end

  def presence(err_msg) : self
    Therapy.new(T) do |input|
      if input.nil?
        Validation::Invalid(T).new(err_msg)
      else
        Validation::Valid(T).new(input)
      end.as(Validation(T))
    end
  end

  def eq(value : T?, err_msg : String) : self
    Therapy.new(T) do |input|
      if input != value
        Validation::Invalid(T).new(err_msg)
      else
        Validation::Valid(T).new(input)
      end.as(Validation(T))
    end
  end

  def is_true(err_msg : String, &block : T -> Bool) : self
    Therapy.new(T) do |input|
      if block.call input
        Validation::Valid(T).new(input)
      else
        Validation::Invalid(T).new(err_msg)
      end
    end
  end

  def lift(higher_type : Y.class, &block : Y -> T) : Therapy(Y) forall Y
    Therapy.new(higher_type) do |input|
      result = block.call(input)
      validated = validate(result)
      if validated.valid?
        Validation::Valid(Y).new(input)
      else
        Validation::Invalid(Y).new(validated.errors)
      end
    end
  end

  def validate(input : T) : Validation(T)
    proc.call(input)
  end

  def validate!(input : T) : T
    validate(input).value
  end

  def transforming(&block : T -> R) : TransformingTherapy(T, R) forall R
    TransformingTherapy.new(self, block)
  end

  class TransformingTherapy(FROM, TO)
    private getter validator : Therapy(FROM)
    private getter transformer : Proc(FROM, TO)

    def initialize(@validator : Therapy(FROM), @transformer : Proc(FROM, TO))
    end

    def validate(input : FROM) : Validation(TO)
      validator.validate(input).map(&transformer)
    end

    def validate!(input : FROM) : TO
      validate(input).value
    end
  end
end
