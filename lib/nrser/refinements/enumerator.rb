require_relative './enumerable'

module NRSER
  refine ::Enumerator do
    include NRSER::Refinements::Enumerable
  end # refine ::Enumerator
end # NRSER
