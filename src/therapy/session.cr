module Therapy
  class Session(IN, OUT, ERR)
    def initialize(&block : IN -> OUT | ERR)
      @transformer = block
    end

    def parse(input : IN) : OUT | ERR
      @transformer.call(input)
    end

    def map(&block : OUT -> NEWOUT) : Session(IN, NEWOUT, ERR) forall NEWOUT
      Session(IN, NEWOUT, ERR).new do |input|
      end
    end
  end

  class FreeSession(INOUT)
    private getter transformer : Proc(INOUT, INOUT)

    def initialize
      @transformer = ->(input : INOUT) { input }
    end

    def parse(input : INOUT) : INOUT
      transformer.call(input)
    end

    def not_nil_or_blank(&block : -> T) : Session(INOUT, String, T) forall T
      Session(INOUT, String, T).new do |input|
        temp = parse(input)
        if temp.nil? || temp.blank?
          block.call
        else
          temp
        end
      end
    end
  end
end
