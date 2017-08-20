require 'nrser/refinements'
require 'nrser/types/where'

using NRSER
  
module NRSER::Types
  ANY = where(name: 'Any', from_s: ->(s) { s }) { true }.freeze
  
  # anything
  def self.any
    ANY
  end
end # NRSER::Types
