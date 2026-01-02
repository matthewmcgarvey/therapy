struct Therapy::BeError
  def initialize(@expected_err_msg : String? = nil)
  end

  def match(actual_value)
    return false unless actual_value.is_a?(Therapy::Result::Failure)

    if err_msg = @expected_err_msg
      actual_err_msg = actual_value.errors.map(&.to_s).join(", ")
      return false if actual_err_msg != err_msg
    end
    true
  end

  def failure_message(actual_value : Therapy::Result::Failure)
    "Expected: #{@expected_err_msg}\n     Got: #{actual_value.errors.map(&.to_s).join(", ")}"
  end

  def failure_message(actual_value)
    "Expected:   #{actual_value.pretty_inspect}\nto be a Therapy::Result::Failure"
  end

  def negative_failure_message(actual_value : Therapy::Result::Failure)
    msg = "Expected: error message not to be Therapy::Result::Failure"
    msg += " with message: #{expected_err_msg}" if expected_err_msg
    msg
  end

  def negative_failure_message(actual_value)
    raise "unreachable"
  end
end
