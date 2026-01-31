class Therapy::TupleType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.map_with_index do |validator, idx|
      val = value[idx]
      new_path = context.full_path.dup
      new_path << idx
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  def create_context(value : V, path : Array(String | Int32)) : ParseContext(OUT, V) forall V
    context = ParseContext(OUT, V).new(value, self, path)
    setup_subcontexts(value, path, context)
    context
  end

  private def setup_subcontexts(value : V, path, context : ParseContext(OUT, V)) forall V
    setup_subcontexts_for(value, path, context)
  end

  private def setup_subcontexts_for(value : JSON::Any, path, context)
    arr = value.as_a?
    return if arr.nil?
    setup_subcontexts_for_array(arr, path, context)
  end

  private def setup_subcontexts_for(value : Array, path, context)
    setup_subcontexts_for_array(value, path, context)
  end

  private def setup_subcontexts_for_array(arr, path, context)
    if arr.size != validators.size
      size_error = Error.new("Must have size of #{validators.size} but was #{arr.size}", path)
      # Set up handlers that will report the size error
      context.with_subcontexts(
        parse: -> { },
        collect_errors: -> { [size_error] },
        assemble: -> { nil.as(OUT?) }
      )
      return
    end
    elem_contexts = validators.map_with_index do |validator, idx|
      val = arr[idx]?
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
      collect_errors: -> { elem_contexts.flat_map(&.errors).to_a },
      assemble: -> { OUT.from(elem_contexts.map(&.result_value).to_a).as(OUT?) }
    )
  end

  def coerce(context : ParseContext(OUT, V)) : Result(OUT) forall V
    if context.has_subcontexts?
      assembled = context.assemble_from_subcontexts
      if assembled
        Result::Success(OUT).new(assembled)
      else
        Result::Failure(OUT).with_msg("Failed to assemble tuple", context.full_path)
      end
    else
      # No subcontexts means input wasn't a valid array type
      coerce_value(context.value, context.full_path)
    end
  end

  private def coerce_value(value : JSON::Any, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected JSON to be an Array but it was a #{value.raw.class}", path)
  end

  private def coerce_value(value, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected Array but got #{value.class}", path)
  end
end
