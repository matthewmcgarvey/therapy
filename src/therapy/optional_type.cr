class Therapy::OptionalType(T) < Therapy::BaseType(T?)
  private getter inner : BaseType(T)

  def initialize(@inner : BaseType(T))
  end

  def optional : OptionalType(T)
    self
  end

  def parse(input : Nil) : Result(T?)
    Result::Success(T?).new(nil)
  end

  def create_context(value : V, path : Array(String | Int32)) : ParseContext(T?, V) forall V
    context = ParseContext(T?, V).new(value, self, path)
    setup_subcontext(value, path, context)
    context
  end

  private def setup_subcontext(value : V, path, context : ParseContext(T?, V)) forall V
    setup_subcontext_for(value, path, context)
  end

  private def setup_subcontext_for(value : JSON::Any, path, context)
    raw_val = value.raw
    return if raw_val.nil?
    inner_ctx = inner.create_context(raw_val, path)
    context.with_subcontexts(
      parse: -> { inner_ctx.do_parse },
      collect_errors: -> { inner_ctx.errors },
      assemble: -> { inner_ctx.result_value.as(T??) }
    )
  end

  private def setup_subcontext_for(value : Nil, path, context)
    # nil value - no subcontext needed
  end

  private def setup_subcontext_for(value, path, context)
    inner_ctx = inner.create_context(value, path)
    context.with_subcontexts(
      parse: -> { inner_ctx.do_parse },
      collect_errors: -> { inner_ctx.errors },
      assemble: -> { inner_ctx.result_value.as(T??) }
    )
  end

  def coerce(context : ParseContext(T?, V)) : Result(T?) forall V
    if context.has_subcontexts?
      assembled = context.assemble_from_subcontexts
      Result::Success(T?).new(assembled)
    else
      # No subcontext means value was nil
      Result::Success(T?).new(nil)
    end
  end

  protected def apply_checks(context : ParseContext(T?, T?)) : Nil
    # TODO: compilation error
    # checks.each(&.check(context))
    value = context.value
    if value
      inner.apply_checks_on_coerced(value, context.full_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end
end
