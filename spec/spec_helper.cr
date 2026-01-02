require "spec"
require "json"
require "http"
require "../src/therapy"
require "./support/be_error"

module Spec::Expectations
  def be_error(msg : String? = nil)
    Therapy::BeError.new(msg)
  end
end
