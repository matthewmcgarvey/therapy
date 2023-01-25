class Therapy::TupleType(VALIDATORS, OUT) < Therapy::BaseType(OUT)
  private getter validators : VALIDATORS

  def initialize(@validators)
  end

  protected def _parse(input : ParseContext(OUT, OUT)) : Result(OUT)
    results = validators.map_with_index do |validator, idx|
      value = input.value[idx]
      sub_context = validator.create_subcontext(input, value, path: idx)
      validator._parse(sub_context)
      sub_context.to_result
    end

    checks.each(&.check(input))

    if results.all?(&.success?) && input.errors.none?
      Result::Success(OUT).new(input.value)
    else
      item_errors = results.flat_map(&.errors)
      tuple_errors = input.errors
      Result::Failure(OUT).new(item_errors + tuple_errors)
    end
  end

  protected def _do_coerce(context : ParseContext(OUT, Array))
    context.map_result do |val|
      results = validators.map_with_index do |validator, idx|
        value = val[idx]?
        sub_context = validator.create_subcontext(context, value, path: idx)
        validator.coerce(sub_context).to_result
      end

      if results.all?(&.success?)
        Result::Success(OUT).new(OUT.from(results.map(&.value).to_a))
      else
        Result::Failure(OUT).new(results.flat_map(&.errors))
      end
    end
  end

  protected def _do_coerce(context : ParseContext(OUT, JSON::Any))
    context.map_result do |val|
      if arr = val.as_a?
        results = validators.map_with_index do |validator, idx|
          value = val[idx]?
          sub_context = validator.create_subcontext(context, value.try(&.raw), path: idx)
          validator.coerce(sub_context).to_result
        end

        if results.all?(&.success?)
          Result::Success(OUT).new(OUT.from(results.map(&.value).to_a))
        else
          Result::Failure(OUT).new(results.flat_map(&.errors))
        end
      else
        Result::Failure(OUT).with_msg("Expected #{OUT} got #{val.raw.class}")
      end
    end
  end
end
