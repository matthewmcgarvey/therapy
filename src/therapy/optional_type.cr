class Therapy::OptionalType(T) < Therapy::BaseType(T?)
  private getter inner : BaseType(T)

  def initialize(@inner : BaseType(T))
  end

  def optional : OptionalType(T)
    self
  end

  def parse(input : T?) : T?
    if input.nil?
      nil
    else
      inner.parse(input)
    end
  end

  def coerce(input) : T?
    return nil if input.nil?

    inner.coerce(input)
  end
end