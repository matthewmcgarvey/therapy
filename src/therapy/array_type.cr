class Therapy::ArrayType(T) < Therapy::BaseType(Array(T))
  private getter validator : BaseType(T)

  def initialize(@validator)
  end

  protected def _parse(context : ParseContext(Array(T), Array(T))) : Result(Array(T))
    results = context.value.map_with_index do |value, idx|
      sub_context = validator.create_subcontext(context, value, path: idx)
      validator._parse(sub_context)
      sub_context.to_result
    end

    checks.each(&.check(context))

    if results.all?(&.success?)
      Result::Success.new(context.value)
    else
      item_errors = results.flat_map(&.errors)
      arr_errors = context.errors
      Result::Failure(Array(T)).new(item_errors + arr_errors)
    end
  end

  protected def _do_coerce(context : ParseContext(Array(T), Array))
    context.map_result do |arr|
      results = arr.map_with_index do |value, idx|
        sub_context = validator.create_subcontext(context, value, path: idx)
        validator.coerce(sub_context).to_result
      end

      if results.all?(&.success?)
        Result::Success.new(results.map(&.value.as(T)))
      else
        item_errors = results.flat_map(&.errors)
        Result::Failure(Array(T)).new(item_errors)
      end
    end
  end

  protected def _do_coerce(context : ParseContext(Array(T), JSON::Any))
    context.map_result do |val|
      if arr = val.as_a?
        results = arr.map_with_index do |value, idx|
          sub_context = validator.create_subcontext(context, value, path: idx)
          validator.coerce(sub_context).to_result
        end

        if results.all?(&.success?)
          Result::Success.new(results.map(&.value.as(T)))
        else
          item_errors = results.flat_map(&.errors)
          Result::Failure(Array(T)).new(item_errors)
        end
      else
        Result::Failure(Array(T)).with_msg("Expected #{Array(T)} got #{val.raw.class}")
      end
    end
  end
end
