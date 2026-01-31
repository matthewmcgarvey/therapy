class Therapy::ObjectType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  def validate(err_msg : String, path : Array(String | Int32)? = nil, &validation : OUT -> Bool) : self
    add_validation(validation, err_msg, path.try(&.map(&.as(String | Int32))))
  end

  protected def apply_checks(context : ParseContext(OUT, OUT)) : Nil
    checks.each(&.check(context))
    value = context.value
    validators.each do |key, validator|
      val = value[key]
      new_path = context.full_path.dup
      new_path << key.to_s
      validator.apply_checks_on_coerced(val, new_path)
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  protected def create_context(value : V, path : Array(String | Int32)) : ParseContext(OUT, V) forall V
    context = ParseContext(OUT, V).new(value, self, path)
    setup_subcontexts(value, path, context)
    context
  end

  private def setup_subcontexts(value : V, path, context : ParseContext(OUT, V)) forall V
    setup_subcontexts_for(value, path, context)
  end

  private def setup_subcontexts_for(value : JSON::Any, path, context)
    hash = value.as_h?
    return if hash.nil?
    # Create typed subcontexts for each field
    field_contexts = validators.map do |key, validator|
      val = hash[key.to_s]?
      {key, validator.create_context(val, path + [key.to_s.as(String | Int32)])}
    end
    setup_context_handlers(field_contexts, context)
  end

  private def setup_subcontexts_for(value : URI::Params, path, context)
    field_contexts = validators.map do |key, validator|
      val = if validator.is_a?(ArrayType) || validator.is_a?(TupleType)
              value.fetch_all(key.to_s)
            else
              value[key.to_s]?
            end
      {key, validator.create_context(val, path + [key.to_s.as(String | Int32)])}
    end
    setup_context_handlers(field_contexts, context)
  end

  private def setup_subcontexts_for(value : Hash, path, context)
    field_contexts = validators.map do |key, validator|
      val = value[key.to_s]?
      {key, validator.create_context(val, path + [key.to_s.as(String | Int32)])}
    end
    setup_context_handlers(field_contexts, context)
  end

  private def setup_subcontexts_for(value : NamedTuple, path, context)
    field_contexts = validators.map do |key, validator|
      val = value[key]?
      {key, validator.create_context(val, path + [key.to_s.as(String | Int32)])}
    end
    setup_context_handlers(field_contexts, context)
  end

  private def setup_subcontexts_for(value, path, context)
    # Unknown type - no subcontexts, coerce will fail
  end

  private def setup_context_handlers(field_contexts, context)
    context.with_subcontexts(
      parse: -> { field_contexts.each { |_, ctx| ctx.do_parse } },
      collect_errors: -> { field_contexts.flat_map { |_, ctx| ctx.errors } },
      assemble: -> {
        hash = field_contexts.map { |key, ctx| {key, ctx.result_value} }.to_h
        OUT.from(hash).as(OUT?)
      }
    )
  end

  protected def coerce(context : ParseContext(OUT, V)) : Result(OUT) forall V
    if context.has_subcontexts?
      # Assemble result from parsed subcontexts
      assembled = context.assemble_from_subcontexts
      if assembled
        Result::Success(OUT).new(assembled)
      else
        Result::Failure(OUT).with_msg("Failed to assemble object", context.full_path)
      end
    else
      # No subcontexts means input wasn't a valid hash-like type
      coerce_value(context.value, context.full_path)
    end
  end

  private def coerce_value(value : JSON::Any, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected JSON to be a Hash but it was a #{value.raw.class}", path)
  end

  private def coerce_value(value, path) : Result(OUT)
    Result::Failure(OUT).with_msg("Expected Hash-like input but got #{value.class}", path)
  end
end
