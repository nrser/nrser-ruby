require 'nrser/refinements'
require 'nrser/types/where'

  
module NRSER::Types
  ANY = where(name: 'AnyType', from_s: ->(s) { s }) { true }.freeze
  
  # anything
  def self.any
    ANY
  end
end # NRSER::Types
