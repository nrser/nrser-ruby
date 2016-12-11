require 'nrser/refinements'
require 'nrser/types/combinators'

using NRSER
  
module NRSER::Types
  # nil or the argument type
  def self.maybe type
    union nil, type, name: "Maybe(#{ type.name })"
  end
end # NRSER::Types
