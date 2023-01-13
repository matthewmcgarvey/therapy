class Therapy::CoercingType(T) < Therapy::BaseType(T)
  private getter inner : BaseType(T)

  def initialize(@inner : BaseType(T))
  end

  def parse(input) : T
    if input.nil?
      {% if T.nilable? %}
        return nil
      {% else %}
        raise "input was nil and it shouldn't be"  
      {% end %}
    end

    inner.parse(coerce(input))
  end

  protected def coerce(input) : T
    inner.coerce(input)
  end
end
