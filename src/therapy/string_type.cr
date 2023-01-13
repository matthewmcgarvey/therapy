class Therapy::StringType < Therapy::BaseType(String)
  private getter checks = [] of {check: String -> Bool, msg: String}

  def parse(input : String) : Result(String)
    results = checks.reject { |check| check[:check].call(input) }
      .map { |check| check[:msg] }

    if results.any?
      Result::Failure(String).new(results)
    else
      Result::Success.new(input)
    end
  end

  def min(size : Int32) : self
    checks << {
      check: ->(input: String) { input.size >= size },
      msg: "Must be at least #{size}"
    }

    self
  end

  protected def coerce(input) : String
    input.to_s
  end
end