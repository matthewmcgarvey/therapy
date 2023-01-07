require "./therapy/session"

module Therapy
  def self.from_nilable_string : FreeSession(String?)
    from(String?)
  end

  def self.from(_klass : T.class) : FreeSession(T) forall T
    FreeSession(T).new
  end
end
