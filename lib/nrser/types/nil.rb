require 'nrser/types/is'
  
module NRSER::Types

  NIL_TYPE = is(
    nil,
    name: 'NilType',
    # from_s: ->( s ) {
    #   
    # }
  ).freeze
  
  # nothing
  def self.nil
    NIL_TYPE
  end
end # NRSER::Types
