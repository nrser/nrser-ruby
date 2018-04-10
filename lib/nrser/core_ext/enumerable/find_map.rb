module Enumerable
  
  # Find the first truthy (not `nil` or `false`) result of calling `&block`
  # on entries.
  # 
  # Like {Enumerable#find}, accepts an optional `ifnone` procedure to call if
  # no match is found.
  # 
  # @example
  #   
  #   [1, 2, 3, 4].find_map do |i|
  #     if i.even?
  #       "#{ i } is even!"
  #     end
  #   end
  #   # => "2 is even!"
  # 
  # @param [nil | Proc<()=>DEFAULT>] ifnone
  #   Optional lambda to call for the return value when no match is found.
  # 
  # @param [Proc<(E)=>RESLUT>] &block
  #   Block mapping entires to results.
  # 
  # @return [nil]
  #   When `block.call( E )` is `nil` or `false` for all entries `E`
  #   *and* `ifnone` is `nil` or not provided.
  # 
  # @return [V]
  #   When `block.call( E )` is `nil` or `false` for all entries `E`
  #   *and* `ifnone` is a lambda that returns `DEFAULT`.
  # 
  # @return [RESULT]
  #   The first result `RESLUT = block.call( E )`
  #   where `RESLUT` is not `nil` or `false`.
  # 
  # @return [DEFAULT]
  #   When `ifnone` procedure is provided and `&block` returns `nil` or
  #   `false` for all entries.
  # 
  # @return [nil]
  #   When `ifnone` procedure is *not* provided and `&block` returns `nil` or
  #   `false` for all entries.
  # 
  def find_map ifnone = nil, &block
    each do |entry|
      if result = block.call( entry )
        # Found a match, short-circuit
        return result
      end
    end
    
    # No matches, return `ifnone`
    ifnone.call if ifnone
  end # #find_map
  
end # module NRSER
