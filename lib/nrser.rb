require 'pathname'

module NRSER
  ROOT = ( Pathname.new(__FILE__).dirname / '..' ).expand_path
end

require_relative './nrser/version'
require_relative './nrser/no_arg'
require_relative './nrser/op/message'
require_relative './nrser/collection'
require_relative './nrser/object'
require_relative './nrser/string'
require_relative './nrser/binding'
require_relative './nrser/exception'
require_relative './nrser/enumerable'
require_relative './nrser/hash'
require_relative './nrser/array'
require_relative './nrser/types'
require_relative './nrser/meta'
require_relative './nrser/open_struct'
require_relative './nrser/merge_by'
require_relative './nrser/tree'
