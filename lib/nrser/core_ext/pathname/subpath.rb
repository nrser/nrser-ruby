# frozen_string_literal: true
# encoding: UTF-8

require 'nrser/etc/pathname/subpath'

class Pathname
  prepend NRSER::Ext::Pathname  
end # class Pathname
