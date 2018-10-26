# frozen_string_literal: true
# encoding: UTF-8

# Using {String#squish}
require 'active_support/core_ext/string/filters'

class String
  # Format strings written as text blocks.
  # 
  # Right now, it just calls {#squish}, but I would like to make it a bit
  # smarter soon so it can be used on paragraph-structured text too.
  # 
  # It's meant to be used with the `%{}` string quote form, because that allows
  # multi-line strings, but nothing stopping it from being used elsewhere too.
  # 
  # @example
  #   ~%{
  #     Hey there, here's some "stuff",
  #     and here's some MORE!
  #   }
  #   # => "Hey there, here's some \"stuff\", and here's some MORE!"
  # 
  # @return [String]
  # 
  def ~@
    squish
  end
end
