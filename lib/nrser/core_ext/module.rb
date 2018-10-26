# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/module'

class Module
  prepend NRSER::Ext::Module
end
