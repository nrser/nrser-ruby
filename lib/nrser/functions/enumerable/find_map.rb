module NRSER
  
  # @!group Enumerable Functions
  
  # Find the first truthy (not `nil` or `false`) result of calling `&block`
  # with entries from `enum`.
  # 
  # Like {Enumerable#find}, accept an optional `ifnone` procedure to call if
  # no match is found.
  # 
  # @example
  #   
  #   NRSER.find_map( [1, 2, 3, 4] ) do |i|
  #     if i.even?
  #       "#{ i } is even!"
  #     end
  #   end
  #   # => "2 is even!"
  # 
  # @param [Enumerable<E>] enum
  #   Entries to search (in order).
  # 
  # @param [nil | Proc<()=>DEFAULT>] ifnone
  #   Optional lambda to call for the return value when no match is found.
  # 
  # @param [Proc<(E)=>RESLUT>] &block
  #   Block mapping entires to results.
  # 
  # @return [nil]
  #   When `block.call( E )` is `nil` or `false` for all `E` in `enum`
  #   *and* `ifnone` is `nil` or not provided.
  # 
  # @return [V]
  #   When `block.call( E )` is `nil` or `false` for all `E` in `enum`
  #   *and* `ifnone` is a lambda that returns `DEFAULT`.
  # 
  # @return [R]
  #   The first result `RESLUT = block.call( E )`
  #   where `RESLUT` is not `nil` or `false`.
  # 
  def self.find_map enum, ifnone = nil, &block
    enum.each do |entry|
      if result = block.call( entry )
        # Found a match, short-circuit
        return result
      end
    end
    
    # No matches, return `ifnone`
    ifnone.call if ifnone
  end # .find_map
  
end # module NRSER
