require 'nrser/types/combinators'

module NRSER::Types
    
  # nil or the argument type
  def self.maybe type, **options
    union self.nil, type, name: "#{ type.name }?", **options
  end
  
end # NRSER::Types
