module Therapy
  class Session(IN, OUT, ERR)
    private getter transformer : Proc(IN, Validated(ERR, OUT))

    def initialize(&block : IN -> Validated(ERR, OUT))
      @transformer = block
    end

    def parse(input : IN) : Validated(ERR, OUT)
      @transformer.call(input)
    end

    # Must use inferrencing for return type because it is not possible to specify the OUT -> !OUT transition.
    # This typeof hack is how the core language accomplishes this transition currently.
    # ref: https://github.com/crystal-lang/crystal/blob/5402f6a38f69e45d4c20fa0ee685ffb6f1aa416b/src/enumerable.cr#L231
    def not_nil(&block : -> ERR)
      and_then do |input|
        temp = input
        if input.nil?
          Validated::Invalid(ERR, typeof(temp.not_nil!)).new(block.call)
        else
          Validated::Valid(ERR, typeof(temp.not_nil!)).new(input)
        end
      end
    end

    # Uses inferrencing to allow the OUT type to become nilable if not already
    def presence
      map { |input| input.presence }
    end

    def not_nil_or_blank(&block : -> ERR)
      presence.not_nil(&block)
    end

    def size(size : Int32, &block : OUT -> ERR) : Session(IN, OUT, ERR)
      and_then do |input|
        if input && input.size != size
          Validated::Invalid(ERR, OUT).new(block.call(input))
        else
          Validated::Valid(ERR, OUT).new(input)
        end
      end
    end

    def min_size(size : Int32, &block : OUT -> ERR) : Session(IN, OUT, ERR)
      and_then do |input|
        if input && input.size < size
          Validated::Invalid(ERR, OUT).new(block.call(input))
        else
          Validated::Valid(ERR, OUT).new(input)
        end
      end
    end

    def max_size(size : Int32, &block : OUT -> ERR) : Session(IN, OUT, ERR)
      and_then do |input|
        if input && input.size > size
          Validated::Invalid(ERR, OUT).new(block.call(input))
        else
          Validated::Valid(ERR, OUT).new(input)
        end
      end
    end

    def upcase : Session(IN, OUT, ERR)
      map { |input| input.try &.upcase }
    end

    def downcase : Session(IN, OUT, ERR)
      map { |input| input.try &.downcase }
    end

    def boolean(&block : OUT -> ERR)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Bool?, ERR).new do |input|
          to_bool(parse(input), &temp)
        end
      {% else %}
        Session(IN, Bool, ERR).new do |input|
          to_bool(parse(input), &temp)
        end
      {% end %}
    end

    def i32(&block : OUT -> ERR)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Int32?, ERR).new do |input|
          to_i32(parse(input), &temp)
        end
      {% else %}
        Session(IN, Int32, ERR).new do |input|
          to_i32(parse(input), &temp)
        end
      {% end %}
    end

    def f64(&block : OUT -> ERR)
      temp = block
      {% if OUT.nilable? %}
        Session(IN, Float64?, ERR).new do |input|
          to_f64(parse(input), &temp)
        end
      {% else %}
        Session(IN, Float64, ERR).new do |input|
          to_f64(parse(input), &temp)
        end
      {% end %}
    end

    def min(min, &block : OUT -> ERR) : Session(IN, OUT, ERR)
      and_then do |input|
        if input && input < min
          Validated::Invalid(ERR, OUT).new(block.call(input))
        else
          Validated::Valid(ERR, OUT).new(input)
        end
      end
    end

    def max(max, &block : OUT -> ERR) : Session(IN, OUT, ERR)
      and_then do |input|
        if input && input > max
          Validated::Invalid(ERR, OUT).new(block.call(input))
        else
          Validated::Valid(ERR, OUT).new(input)
        end
      end
    end

    # unable to effectively say what the block return type should be (OUT.not_nil!)
    # so the compilation error when the wrong type is returned from the block is no good
    def with_default(&if_null : -> _)
      and_then do |input|
        temp = input
        Validated::Valid(ERR, typeof(input.not_nil!)).new(input || if_null.call.as(typeof(temp.not_nil!)))
      end
    end

    def map_input(_klass : NEWIN.class, &input_map : NEWIN -> IN) : Session(NEWIN, OUT, ERR) forall NEWIN
      Session(NEWIN, OUT, ERR).new do |input|
        parse(input_map.call(input))
      end
    end

    def map_input(input_map : Proc(NEWIN, IN)) : Session(NEWIN, OUT, ERR) forall NEWIN
      Session(NEWIN, OUT, ERR).new do |input|
        parse(input_map.call(input))
      end
    end

    private def map(&block : OUT -> NEWOUT) : Session(IN, NEWOUT, ERR) forall NEWOUT
      Session(IN, NEWOUT, ERR).new do |input|
        parse(input).map(&block)
      end
    end

    private def and_then(&block : OUT -> Validated(ERR, NEWOUT)) : Session(IN, NEWOUT, ERR) forall NEWOUT
      Session(IN, NEWOUT, ERR).new do |input|
        parse(input).flat_map(&block)
      end
    end

    private def to_bool(validated : Validated(ERR, String), &block : String -> ERR) : Validated(ERR, Bool)
      validated.flat_map do |str|
        case str.downcase
        when "true"
          Validated::Valid(ERR, Bool).new(true)
        when "false"
          Validated::Valid(ERR, Bool).new(false)
        else
          Validated::Invalid(ERR, Bool).new(block.call(str))
        end
      end
    end

    private def to_bool(validated : Validated(ERR, String?), &block : String? -> ERR) : Validated(ERR, Bool?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(ERR, Bool?).new(nil)
        end
        case str.downcase
        when "true"
          Validated::Valid(ERR, Bool?).new(true)
        when "false"
          Validated::Valid(ERR, Bool?).new(false)
        else
          Validated::Invalid(ERR, Bool?).new(block.call(str))
        end
      end
    end

    private def to_i32(validated : Validated(ERR, String), &block : String -> ERR) : Validated(ERR, Int32)
      validated.flat_map do |str|
        if num = str.to_i32?
          Validated::Valid(ERR, Int32).new(num)
        else
          Validated::Invalid(ERR, Int32).new(block.call(str))
        end
      end
    end

    private def to_i32(validated : Validated(ERR, String?), &block : String? -> ERR) : Validated(ERR, Int32?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(ERR, Int32?).new(nil)
        end
        if num = str.to_i32?
          Validated::Valid(ERR, Int32?).new(num)
        else
          Validated::Invalid(ERR, Int32?).new(block.call(str))
        end
      end
    end

    private def to_f64(validated : Validated(ERR, String), &block : String -> ERR) : Validated(ERR, Float64)
      validated.flat_map do |str|
        if num = str.to_f64?
          Validated::Valid(ERR, Float64).new(num)
        else
          Validated::Invalid(ERR, Float64).new(block.call(str))
        end
      end
    end

    private def to_f64(validated : Validated(ERR, String?), &block : String? -> ERR) : Validated(ERR, Float64?)
      validated.flat_map do |str|
        if str.nil?
          next Validated::Valid(ERR, Float64?).new(nil)
        end
        if num = str.to_f64?
          Validated::Valid(ERR, Float64?).new(num)
        else
          Validated::Invalid(ERR, Float64?).new(block.call(str))
        end
      end
    end
  end
end
