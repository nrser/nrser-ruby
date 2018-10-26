# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/module/source_locations'

class Module
  prepend NRSER::Ext::Module
end
