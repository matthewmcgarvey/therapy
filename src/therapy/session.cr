module Therapy
  class Session(IN, OUT)
    private getter transformer : Proc(IN, Validated(OUT))

    def initialize(&block : IN -> Validated(OUT))
      @transformer = block
    end

    def parse(input : IN) : Validated(OUT)
      @transformer.call(input)
    end

    # Must use inferrencing for return type because it is not possible to specify the OUT -> !OUT transition.
    # This typeof hack is how the core language accomplishes this transition currently.
    # ref: https://github.com/crystal-lang/crystal/blob/5402f6a38f69e45d4c20fa0ee685ffb6f1aa416b/src/enumerable.cr#L231
    def not_nil(&block : -> String)
      and_then do |input|
        temp = input
        if input.nil?
          Validated::Invalid(typeof(temp.not_nil!)).new(block.call)
        else
          Validated::Valid(typeof(temp.not_nil!)).new(input)
        end
      end
    end

    # Uses inferrencing to allow the OUT type to become nilable if not already
    def presence
      map { |input| input.presence }
    end

    def not_nil_or_blank(&block : -> String)
      presence.not_nil(&block)
    end

    def size(size : Int32, &block : OUT -> String) : Session(IN, OUT)
      and_then do |input|
        if input && input.size != size
          Validated::Invalid(OUT).new(block.call(input))
        else
          Validated::Valid(OUT).new(input)
        end
      end
    end

    def min_size(size : Int32, &block : OUT -> String) : Session(IN, OUT)
      and_then do |input|
        if input && input.size < size
          Validated::Invalid(OUT).new(block.call(input))
        else
          Validated::Valid(OUT).new(input)
        end
      end
    end

    def max_size(size : Int32, &block : OUT -> String) : Session(IN, OUT)
      and_then do |input|
        if input && input.size > size
          Validated::Invalid(OUT).new(block.call(input))
        else
          Validated::Valid(OUT).new(input)
        end
      end
    end

    def upcase : Session(IN, OUT)
      map { |input| input.try &.upcase }
    end

    def downcase : Session(IN, OUT)
      map { |input| input.try &.downcase }
    end

    def boolean(&block : OUT -> String)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Bool?).new do |input|
          to_bool(parse(input), &temp)
        end
      {% else %}
        Session(IN, Bool).new do |input|
          to_bool(parse(input), &temp)
        end
      {% end %}
    end

    def i32(&block : OUT -> String)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Int32?).new do |input|
          to_i32(parse(input), &temp)
        end
      {% else %}
        Session(IN, Int32).new do |input|
          to_i32(parse(input), &temp)
        end
      {% end %}
    end

    def f64(&block : OUT -> String)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Float64?).new do |input|
          to_f64(parse(input), &temp)
        end
      {% else %}
        Session(IN, Float64).new do |input|
          to_f64(parse(input), &temp)
        end
      {% end %}
    end

    def min(min, &block : OUT -> String) : Session(IN, OUT)
      and_then do |input|
        if input && input < min
          Validated::Invalid(OUT).new(block.call(input))
        else
          Validated::Valid(OUT).new(input)
        end
      end
    end

    def max(max, &block : OUT -> String) : Session(IN, OUT)
      and_then do |input|
        if input && input > max
          Validated::Invalid(OUT).new(block.call(input))
        else
          Validated::Valid(OUT).new(input)
        end
      end
    end

    # unable to effectively say what the block return type should be (OUT.not_nil!)
    # so the compilation error when the wrong type is returned from the block is no good
    def with_default(&if_null : -> _)
      and_then do |input|
        temp = input
        Validated::Valid(typeof(input.not_nil!)).new(input || if_null.call.as(typeof(temp.not_nil!)))
      end
    end

    private def map(&block : OUT -> NEWOUT) : Session(IN, NEWOUT) forall NEWOUT
      Session(IN, NEWOUT).new do |input|
        parse(input).map(&block)
      end
    end

    private def and_then(&block : OUT -> Validated(NEWOUT)) : Session(IN, NEWOUT) forall NEWOUT
      Session(IN, NEWOUT).new do |input|
        parse(input).flat_map(&block)
      end
    end

    private def to_bool(validated : Validated(String), &block : String -> String) : Validated(Bool)
      validated.flat_map do |str|
        case str.downcase
        when "true"
          Validated::Valid(Bool).new(true)
        when "false"
          Validated::Valid(Bool).new(false)
        else
          Validated::Invalid(Bool).new(block.call(str))
        end
      end
    end

    private def to_bool(validated : Validated(String?), &block : String? -> String) : Validated(Bool?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(Bool?).new(nil)
        end
        case str.downcase
        when "true"
          Validated::Valid(Bool?).new(true)
        when "false"
          Validated::Valid(Bool?).new(false)
        else
          Validated::Invalid(Bool?).new(block.call(str))
        end
      end
    end

    private def to_i32(validated : Validated(String), &block : String -> String) : Validated(Int32)
      validated.flat_map do |str|
        if num = str.to_i32?
          Validated::Valid(Int32).new(num)
        else
          Validated::Invalid(Int32).new(block.call(str))
        end
      end
    end

    private def to_i32(validated : Validated(String?), &block : String? -> String) : Validated(Int32?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(Int32?).new(nil)
        end
        if num = str.to_i32?
          Validated::Valid(Int32?).new(num)
        else
          Validated::Invalid(Int32?).new(block.call(str))
        end
      end
    end

    private def to_f64(validated : Validated(String), &block : String -> String) : Validated(Float64)
      validated.flat_map do |str|
        if num = str.to_f64?
          Validated::Valid(Float64).new(num)
        else
          Validated::Invalid(Float64).new(block.call(str))
        end
      end
    end

    private def to_f64(validated : Validated(String?), &block : String? -> String) : Validated(Float64?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(Float64?).new(nil)
        end
        if num = str.to_f64?
          Validated::Valid(Float64?).new(num)
        else
          Validated::Invalid(Float64?).new(block.call(str))
        end
      end
    end
  end
end
