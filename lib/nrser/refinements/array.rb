require_relative './enumerable'

module NRSER
  refine ::Array do
    include NRSER::Refinements::Enumerable
    
    
    # @return [Array]
    #   new array consisting of all elements after the first (which may be 
    #   none, resulting in an empty array).
    # 
    def rest
      NRSER.rest self
    end # #rest
    
  end # refine ::Array
end # NRSER