# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/dynamic_binding'

class Object
  prepend NRSER::Ext::DynamicBinding
end