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
  
  
  # A destructive partition.
  def self.extract_from_array! array, &block
    extracted = []
    array.reject! { |entry|
      test = block.call entry
      if test
        extracted << entry
      end
      test
    }
    extracted
  end
  
  
end # module NRSER