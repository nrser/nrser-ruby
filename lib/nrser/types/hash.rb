require 'nrser/refinements'
require 'nrser/types/type'

using NRSER
  
module NRSER::Types

  class Hash < NRSER::Types::Type
    attr_reader :keys, :values, :including, :exactly, :min, :max
    
    def initialize options = {}
      
    end
  end # Hash
end
