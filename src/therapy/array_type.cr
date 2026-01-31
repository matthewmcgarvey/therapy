class Therapy::ArrayType(T) < Therapy::BaseType(Array(T))
  private getter validator : BaseType(T)

  def initialize(@validator)
  end

  protected def apply_checks(context : ParseContext(Array(T), Array(T))) : Nil
    checks.each(&.check(context))
    value = context.value
    value.each_with_index do |val, idx|
      new_path = context.full_path.dup
      new_path << idx
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  protected def create_context(value : V, path : Array(String | Int32)) : ParseContext(Array(T), V) forall V
    context = ParseContext(Array(T), V).new(value, self, path)
    setup_subcontexts(value, path, context)
    context
  end

  private def setup_subcontexts(value : V, path, context : ParseContext(Array(T), V)) forall V
    setup_subcontexts_for(value, path, context)
  end

  private def setup_subcontexts_for(value : JSON::Any, path, context)
    arr = value.as_a?
    return if arr.nil?
    elem_contexts = arr.map_with_index do |val, idx|
      validator.create_context(val, path + [idx.as(String | Int32)])
    end
    setup_context_handlers(elem_contexts, context)
  end

  private def setup_subcontexts_for(value : Array, path, context)
    elem_contexts = value.map_with_index do |val, idx|
      validator.create_context(val, path + [idx.as(String | Int32)])
    end
    setup_context_handlers(elem_contexts, context)
  end

  private def setup_subcontexts_for(value, path, context)
    # Unknown type - no subcontexts, coerce will fail
  end

  private def setup_context_handlers(elem_contexts, context)
    context.with_subcontexts(
      parse: -> { elem_contexts.each(&.do_parse) },
      collect_errors: -> { elem_contexts.flat_map(&.errors) },
      assemble: -> { elem_contexts.map(&.result_value).as(Array(T)?) }
    )
  end

  protected def coerce(context : ParseContext(Array(T), V)) : Result(Array(T)) forall V
    if context.has_subcontexts?
      assembled = context.assemble_from_subcontexts
      if assembled
        Result::Success(Array(T)).new(assembled)
      else
        Result::Failure(Array(T)).with_msg("Failed to assemble array", context.full_path)
      end
    else
      # No subcontexts means input wasn't a valid array type
      coerce_value(context.value, context.full_path)
    end
  end

  private def coerce_value(value : JSON::Any, path) : Result(Array(T))
    Result::Failure(Array(T)).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}", path)
  end

  private def coerce_value(value, path) : Result(Array(T))
    Result::Failure(Array(T)).with_msg("Expected Array but got #{value.class}", path)
  end
end
