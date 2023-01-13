class Therapy::StringType < Therapy::BaseType(String)
  private getter checks = [] of {check: String -> Bool, msg: String}

  def parse(input : String) : String
    checks.each do |check|
      if !check[:check].call(input)
        raise check[:msg]
      end
    end

    input
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