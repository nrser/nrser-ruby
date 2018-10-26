# frozen_string_literal: true
# encoding: UTF-8

require 'nrser/ext/array'

class Array
  prepend NRSER::Ext::Array
end # class Array
