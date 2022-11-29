module Therapy
  private abstract class BaseValidation
    getter errors : Array(String) { [] of String }
  end

  abstract class Validation(T) < BaseValidation
    abstract def value : T
    abstract def valid? : Bool

    def valid! : Bool
      valid? || raise "invalid #{errors}"
    end

    def eq(other : T, err_msg = "must equal expected value") : Validation(T)
      return self unless valid?

      if self.value == other
        Valid(T).new(value)
      else
        Invalid(T).new(err_msg)
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
