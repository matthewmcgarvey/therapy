class Therapy::Error
  getter message : String
  # String | Int32 because the path to the field could be through an array
  getter path : Array(String | Int32)

  def initialize(@message, @path = [] of String | Int32)
  end

  def to_s : String
    if path.empty?
      message
    else
      "#{path}: #{message}"
    end
  end
end
