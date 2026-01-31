class Therapy::UnionType(L, R) < Therapy::BaseType(L | R)
  private getter left : BaseType(L)
  private getter right : BaseType(R)

  def initialize(@left : BaseType(L), @right : BaseType(R))
  end

  protected def coerce(context : ParseContext(L | R, V)) : Result(L | R) forall V
    left_result = left.create_context(context.value, context.full_path).parse
    if left_result.success?
      return Result::Success(L | R).new(left_result.value.as(L | R))
    end

    right_result = right.create_context(context.value, context.full_path).parse
    if right_result.success?
      return Result::Success(L | R).new(right_result.value.as(L | R))
    end

    Result::Failure(L | R).new(left_result.errors.concat(right_result.errors))
  end
end
