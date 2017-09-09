require_relative './enumerable'

module NRSER
  refine ::Array do
    include NRSER::Refinements::Enumerable
  end # refine ::Array
end # NRSER