class Therapy(T)
  private abstract class BaseValidation
    getter errors : Array(String) { [] of String }
  end

  abstract class Validation(T) < BaseValidation
    def self.compose(*validateds : Validation(T)) : Validation(T) forall T
      if validateds.all?(&.valid?)
        Valid(T).new(validateds.first.value)
      else
        Invalid(T).of(*validateds)
      end
    end

    abstract def value : T
    abstract def valid? : Bool

    def map(&block : T -> R) : Validation(R) forall R
      if valid?
        result = yield value
        Valid(R).new(result)
      else
        Invalid(R).new(errors)
      end
    end

    class Valid(T) < Validation(T)
      getter value : T

      def initialize(@value)
      end

      def valid? : Bool
        true
      end
    end

    class Invalid(T) < Validation(T)
      def self.of(*validations : BaseValidation) : Invalid(T)
        new(validations.flat_map(&.errors))
      end

      def initialize(@errors : Array(String))
      end

      def initialize(error : String)
        @errors = [error]
      end

      def value : T
        raise "invalid #{errors}"
      end

      def valid? : Bool
        false
      end
    end
  end
end
