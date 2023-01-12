require "./therapy/session"
require "./therapy/validated"

module Therapy
  def self.from_nilable_string : Session(String?, String?, String)
    from(String?)
  end

  def self.from(_klass : T.class) : Session(T, T, String) forall T
    Session(T, T, String).new { |input| Validated::Valid(String, T).new(input) }
  end
end
