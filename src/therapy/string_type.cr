class Therapy::StringType < Therapy::BaseType(String)
  def min(size : Int32) : self
    add_validation(
      ->(str : String) { str.size >= size },
      "Must be at least #{size}"
    )
  end

  def max(size : Int32) : self
    add_validation(
      ->(str : String) { str.size <= size },
      "Must be at most #{size}"
    )
  end

  def size(size : Int32) : self
    add_validation(
      ->(str : String) { str.size == size },
      "Must be exactly #{size}"
    )
  end

  def one_of(*options) : self
    one_of(options.to_a)
  end

  def one_of(options : Array(String)) : self
    add_validation(
      ->(str : String) { options.includes?(str) },
      "Must be one of: #{options.join(", ")}"
    )
  end

  def starts_with(prefix : String) : self
    add_validation(
      ->(str : String) { str.starts_with?(prefix) },
      "Must start with #{prefix}"
    )
  end

  def ends_with(suffix : String) : self
    add_validation(
      ->(str : String) { str.ends_with?(suffix) },
      "Must end with #{prefix}"
    )
  end

  def matches(regex : Regex) : self
    add_validation(
      ->(str : String) { str.matches?(regex) },
      "Must match #{regex}"
    )
  end

  def strip : self
    add_check do |ctx|
      ctx.value = ctx.value.strip
    end
  end

  protected def _coerce(value : Int32) : Result(String)
    Result::Success.new(value.to_s)
  end

  protected def _coerce(value : JSON::Any) : Result(String)
    _coerce(value.raw)
  end
end
