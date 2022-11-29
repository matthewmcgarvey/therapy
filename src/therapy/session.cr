class Therapy::Session
  private getter form : URI::Params

  def initialize(@form)
  end

  def parse_str(name : String) : Validation(String)
    parse(name, type: String)
  end

  def parse_str?(name : String) : Validation(String?)
    parse(name, type: String?)
  end

  def parse(name : String, type : T.class) : Validation(T) forall T
    if !form.has_key?(name)
      {% if T.nilable? %}
        return Validation::Valid(T).new(nil)
      {% else %}
        return Validation::Invalid(T).new("must be present")
      {% end %}
    end

    values = form.fetch_all(name)
    convert(values, to: type)
  end

  private def convert(values : Array(String), to type : Array(T).class) : Validation(Array(T)) forall T
    validations = values.map { |val| convert(val, type: T) }
    if validations.all?(&.valid?)
      Validation::Valid.new(validations.map(&.value))
    else
      Validation::Invalid(Array(T)).of(validations)
    end
  end

  private def convert(values : Array(String), to type : T.class) : Validation(T) forall T
    convert(values.first, to: T)
  end

  private def convert(value : String, to type : T.class) : Validation(T) forall T
    result = case type
             when String
               value
             when Int32
               value.to_i32
             when Int64
               value.to_i64
             when Float64
               value.to_f64
             else
               raise "TODO: handle #{type}"
             end
    Validation::Valid(T).new(result.as(T))
  rescue e
    Validation::Invalid(T).new("unable to convert to expected type (#{e.message || "no error message"})")
  end
end
