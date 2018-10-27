# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/symbol'

class Symbol
  prepend NRSER::Ext::Symbol  
end # class Symbol
