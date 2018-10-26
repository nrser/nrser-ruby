# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/object'

class Object
  prepend NRSER::Ext::Object
end # class Object
