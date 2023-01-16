class Therapy::StringType < Therapy::BaseType(String)
  def min(size : Int32) : self
    checks << Check(String).valid("Must be at least #{size}") { |str| str.size >= size }

    self
  end

  def max(size : Int32) : self
    checks << Check(String).valid("Must be at most #{size}") { |str| str.size <= size }

    self
  end

  def size(size : Int32) : self
    checks << Check(String).valid("Must be exactly #{size}") { |str| str.size == size }

    self
  end

  def one_of(*options) : self
    one_of(options.to_a)
  end

  def one_of(options : Array(String)) : self
    err_msg = "Msut be one of: #{options.join(", ")}"
    checks << Check(String).valid(err_msg) { |str| options.includes?(str) }

    self
  end

  def starts_with(prefix : String) : self
    err_msg = "Must start with #{prefix}"
    checks << Check(String).valid(err_msg) { |str| str.starts_with?(prefix) }

    self
  end

  def ends_with(suffix : String) : self
    err_msg = "Must end with #{suffix}"
    checks << Check(String).valid(err_msg) { |str| str.ends_with?(suffix) }

    self
  end

  def matches(regex : Regex) : self
    err_msg = "Must match #{regex}"
    checks << Check(String).valid(err_msg) { |str| str.matches?(regex) }

    self
  end

  def strip : self
    checks << Check(String).new(
      ->(ctx : ParseContext(String)) {  ctx.value = ctx.value.strip }
    )

    self
  end

  def coercing : self
    @coercing = true
    self
  end

  protected def coerce(input) : String
    input.to_s
  end
end