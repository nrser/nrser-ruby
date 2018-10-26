# frozen_string_literal: true
# encoding: UTF-8

require 'nrser/ext/string'

require './string/squiggle'

class String
  prepend NRSER::Ext::String
end
