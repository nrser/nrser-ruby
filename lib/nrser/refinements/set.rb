require 'set'

require_relative './enumerable'

module NRSER
  refine ::Set do
    include NRSER::Refinements::Enumerable
  end # refine ::Set
end # NRSER