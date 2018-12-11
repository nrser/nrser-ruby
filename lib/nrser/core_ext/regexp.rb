# frozen_string_literal: true
# encoding: UTF-8

require 'nrser/ext/regexp'

class Regexp
  prepend NRSER::Ext::Regexp
end
