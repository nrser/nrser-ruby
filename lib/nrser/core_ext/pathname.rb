# frozen_string_literal: true
# encoding: UTF-8

require 'pathname'
require 'nrser/ext/pathname'

class Pathname
  prepend NRSER::Ext::Pathname
end
