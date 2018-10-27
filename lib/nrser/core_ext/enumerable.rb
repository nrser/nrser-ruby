require 'nrser/ext/enumerable'
require 'nrser/core_ext/module/mix'

module Enumerable
  prepend_and_copy NRSER::Ext::Enumerable
end # module Enumerable
