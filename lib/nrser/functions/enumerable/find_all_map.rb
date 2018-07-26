module NRSER
  
  # @!group Enumerable Functions
  
  # Find all truthy (not `nil` or `false`) results of calling `&block`
  # with entries from `enum`.
  # 
  # @example
  #   
  #   NRSER.find_all_map( [1, 2, 3, 4] ) do |i|
  #     if i.even?
  #       "#{ i } is even!"
  #     end
  #   end
  #   # => ["2 is even!", "4 is even!"]
  # 
  # @param [Enumerable<E>] enum
  #   Entries to search (in order).
  # 
  # @param [Proc<(E)=>R>] block
  #   Block mapping entires to results.
  # 
  # @return [nil]
  #   When `block.call( E )` is `nil` or `false` for all `E` in `enum`.
  # 
  # @return [R]
  #   The first result `R = block.call( E )` where `R` is not `nil` or `false`.
  # 
  def self.find_all_map enum, &block
    enum.map( &block ).select { |entry| entry }
  end # .find_map
  
end # module NRSER
