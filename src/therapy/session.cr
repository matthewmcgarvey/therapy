class Therapy::Session
  CONVERSIONS = {
    String   => ->(input : String) { input },
    String?  => ->(input : String) { input },
    Int32    => ->(input : String) { input.to_i32 },
    Int32?   => ->(input : String) { input.to_i32 },
    Int64    => ->(input : String) { input.to_i64 },
    Int64?   => ->(input : String) { input.to_i64 },
    Float64  => ->(input : String) { input.to_f64 },
    Float64? => ->(input : String) { input.to_f64 },
  }

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
    values = form.fetch_all(name).compact_map(&.presence)
    if values.none?
      {% if T.nilable? %}
        return Validation::Valid(T).new(nil)
      {% else %}
        return Validation::Invalid(T).new("must be present")
      {% end %}
    end

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
    convertor = CONVERSIONS[type]? || raise "TODO: handle #{type}"
    Validation::Valid(T).new(convertor.call(value).as(T))
  rescue e
    Validation::Invalid(T).new("unable to convert to expected type (#{e.message || "no error message"})")
  end
end
