abstract class Therapy::BaseType(T)
  def optional : OptionalType(T)
    OptionalType.new(self)
  end

  def coercing : CoercingType(T)
    CoercingType.new(self)
  end

  def parse(input : T) : T
    input
  end

  def parse(input) : T
    raise "can' parse this type"
  end

  protected def coerce(input : T) : T
    input
  end

  protected abstract def coerce(input : _) : T
end