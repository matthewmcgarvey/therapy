class Therapy::HashType(K, V) < Therapy::BaseType(Hash(K, V))
  private getter key_validator : BaseType(K)
  private getter value_validator : BaseType(V)

  def initialize(@key_validator : BaseType(K), @value_validator : BaseType(V))
  end

  protected def apply_checks(context : ParseContext(Hash(K, V), Hash(K, V))) : Nil
    checks.each(&.check(context))
    context.value.each do |key, value|
      path_key = path_key_for(key)
      key_validator.apply_checks_on_coerced(key, context.full_path + [path_key])
        .tap { |errs| context.errors.concat(errs) }
      value_validator.apply_checks_on_coerced(value, context.full_path + [path_key])
        .tap { |errs| context.errors.concat(errs) }
    end
  end

  protected def create_context(value : W, path : Array(String | Int32)) : ParseContext(Hash(K, V), W) forall W
    context = ParseContext(Hash(K, V), W).new(value, self, path)
    setup_subcontexts(value, path, context)
    context
  end

  private def setup_subcontexts(value : W, path, context : ParseContext(Hash(K, V), W)) forall W
    setup_subcontexts_for(value, path, context)
  end

  private def setup_subcontexts_for(value : JSON::Any, path, context)
    hash = value.as_h?
    return if hash.nil?
    pair_contexts = hash.map do |key, val|
      path_key = path_key_for(key)
      {
        key_ctx:   key_validator.create_context(key, path + [path_key]),
        value_ctx: value_validator.create_context(val, path + [path_key]),
      }
    end
    setup_context_handlers(pair_contexts, context)
  end

  private def setup_subcontexts_for(value : Hash, path, context)
    pair_contexts = value.map do |key, val|
      path_key = path_key_for(key)
      {
        key_ctx:   key_validator.create_context(key, path + [path_key]),
        value_ctx: value_validator.create_context(val, path + [path_key]),
      }
    end
    setup_context_handlers(pair_contexts, context)
  end

  private def setup_subcontexts_for(value : URI::Params, path, context)
    keys = [] of String
    value.each do |key, _|
      keys << key unless keys.includes?(key)
    end
    pair_contexts = keys.map do |key|
      val = if value_validator.is_a?(ArrayType) || value_validator.is_a?(TupleType)
              value.fetch_all(key)
            else
              value[key]?
            end
      path_key = path_key_for(key)
      {
        key_ctx:   key_validator.create_context(key, path + [path_key]),
        value_ctx: value_validator.create_context(val, path + [path_key]),
      }
    end
    setup_context_handlers(pair_contexts, context)
  end

  private def setup_subcontexts_for(value, path, context)
    # Unknown type - no subcontexts, coerce will fail
  end

  private def setup_context_handlers(pair_contexts, context)
    context.with_subcontexts(
      parse: -> { pair_contexts.each { |pair| pair[:key_ctx].do_parse; pair[:value_ctx].do_parse } },
      collect_errors: -> {
        pair_contexts.flat_map { |pair| pair[:key_ctx].errors + pair[:value_ctx].errors }
      },
      assemble: -> {
        assembled = Hash(K, V).new
        pair_contexts.each do |pair|
          assembled[pair[:key_ctx].result_value] = pair[:value_ctx].result_value
        end
        assembled.as(Hash(K, V)?)
      }
    )
  end

  protected def coerce(context : ParseContext(Hash(K, V), W)) : Result(Hash(K, V)) forall W
    if context.has_subcontexts?
      assembled = context.assemble_from_subcontexts
      if assembled
        Result::Success(Hash(K, V)).new(assembled)
      else
        Result::Failure(Hash(K, V)).with_msg("Failed to assemble hash", context.full_path)
      end
    else
      coerce_value(context.value, context.full_path)
    end
  end

  private def coerce_value(value : JSON::Any, path) : Result(Hash(K, V))
    Result::Failure(Hash(K, V)).with_msg("Expected JSON to be a Hash but it was a #{value.raw.class}", path)
  end

  private def coerce_value(value, path) : Result(Hash(K, V))
    Result::Failure(Hash(K, V)).with_msg("Expected Hash but got #{value.class}", path)
  end

  private def path_key_for(key) : String | Int32
    key.is_a?(Int32) ? key.as(Int32) : key.to_s
  end
end
