module NRSER  
  
  # Functional implementation of "rest" for arrays. Used when refining `#rest`
  # into {Array}.
  # 
  # @param [Array] array
  # 
  # @return [return_type]
  #   New array consisting of all elements after the first.
  # 
  def self.rest array
    array[1..-1]
  end # .rest
  
end # module NRSER