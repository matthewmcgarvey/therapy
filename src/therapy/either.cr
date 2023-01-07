module Therapy
  abstract class Result(L, R)
    def map(&block : L -> T) : Result(T, R) forall T
      if self.is_a?(Ok)
        new_value = yield self.value
        Ok(T, R).new(new_value)
      else
        Err(T, R).new(self.value)
      end
    end

    class Ok(L, R) < Result(L, R)
      getter value : L

      def initialize(@value)
      end
    end

    class Err(L, R) < Result(L, R)
      getter error : R

      def initialize(@error)
      end
    end
  end
end
