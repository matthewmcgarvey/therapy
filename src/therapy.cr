require "./therapy/validation"
require "./therapy/session"

module Therapy
  VERSION = "0.1.0"

  def self.for(form : URI::Params) : Session
    Session.new(form)
  end
end
