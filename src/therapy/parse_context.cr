class Therapy::ParseContext(T, V)
  getter errors : Array(Therapy::Error) = [] of Therapy::Error
  getter full_path : Array(String | Int32)
  property value : V
  protected getter type : BaseType(T)
  @parse_subcontexts : (-> Nil)?
  @collect_subcontext_errors : (-> Array(Error))?
  @assemble_from_subcontexts : (-> T?)?
  @result : Result(T)?
  @parsed = false

  def initialize(@value, @type, @full_path = [] of String | Int32)
  end

  # Set subcontext handlers - called by container types when creating context
  def with_subcontexts(
    parse : -> Nil,
    collect_errors : -> Array(Error),
    assemble : -> T?,
  ) : self
    @parse_subcontexts = parse
    @collect_subcontext_errors = collect_errors
    @assemble_from_subcontexts = assemble
    self
  end

  def has_subcontexts? : Bool
    !@parse_subcontexts.nil?
  end

  def do_parse : Nil
    return if @parsed
    @parsed = true

    # Parse all subcontexts first
    @parse_subcontexts.try(&.call)

    # Collect subcontext errors - fail early if any failed
    if collector = @collect_subcontext_errors
      sub_errors = collector.call
      if sub_errors.any?
        @errors = sub_errors
        @result = Result::Failure(T).new(sub_errors)
        return
      end
    end

    # Now coerce (container types use subcontext results via assemble)
    @result = type.coerce(self)
    if @result.not_nil!.failure?
      @errors = @result.not_nil!.errors
      return
    end

    # Apply checks (which may transform the value)
    check_ctx = ParseContext(T, T).new(@result.not_nil!.value, type, full_path)
    type.apply_checks(check_ctx)
    if check_ctx.errors.any?
      @errors = check_ctx.errors
      @result = Result::Failure(T).new(check_ctx.errors)
    else
      @result = Result::Success(T).new(check_ctx.value)
    end
  end

  def parse : Result(T)
    do_parse
    @result.not_nil!
  end

  # Called by container types to assemble result from subcontexts
  def assemble_from_subcontexts : T?
    @assemble_from_subcontexts.try(&.call)
  end

  def result_value : T
    @result.not_nil!.value
  end

  def add_error(msg : String, path : Array(String | Int32)? = nil)
    errors << Therapy::Error.new(msg, path: path || full_path)
  end
end
