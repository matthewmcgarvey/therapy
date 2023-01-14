require "./therapy/result"
require "./therapy/parse_context"
require "./therapy/check"
require "./therapy/base_type"
require "./therapy/*"

module Therapy
  def self.string : StringType
    StringType.new
  end

  def self.int32 : Int32Type
    Int32Type.new
  end

  def self.bool : BoolType
    BoolType.new
  end
end
