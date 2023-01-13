class Therapy::Int32Type < Therapy::BaseType(Int32)
  protected def coerce(input : String) : Int32
    input.to_i32
  end

  protected def coerce(input : Bool) : Int32
    input ? 1 : 0
  end
end