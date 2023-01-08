require "./therapy/session"
require "./therapy/validated"

module Therapy
  def self.from_nilable_string : Session(String?, String?)
    from(String?)
  end

  def self.from(_klass : T.class) : Session(T, T) forall T
    Session(T, T).new { |input| Validated::Valid(T).new(input) }
  end
end
