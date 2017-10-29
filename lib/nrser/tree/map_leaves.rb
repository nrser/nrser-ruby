module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    def map_leaves tree, &block
      NRSER::Types.tree.check tree
      
      _internal_map_leaves tree, key_path: [], &block
    end # #map_leaves
    
    private
    # ========================================================================
      
      # Internal recursive implementation for {NRSER.leaves}.
      # 
      # @param [#each_pair | (#each_index & #each_with_index)] tree
      #   Tree to walk.
      # 
      # @param [Array] path
      #   Key path down to `tree`.
      # 
      # @param [Hash<Array, Object>] results
      #   New hash to stick results in.
      # 
      # @return [nil]
      # 
      def _internal_map_leaves tree, key_path:, &block
        NRSER::Types.match tree,
          NRSER::Types.hash_like, ->( hash_like ) {
            hash_like.map { |key, value|
              new_key_path = [*key_path, key]
              
              new_value = if NRSER::Types.tree.test( value )
                _internal_map_leaves value, key_path: new_key_path, &block
              else
                block.call new_key_path, value
              end
              
              [key, new_value]
            }.to_h
          },
          
          NRSER::Types.array_like, ->( array_like ) {
            array_like.each_with_index.map { |value, index|
              new_key_path = [*key_path, index]
              
              if NRSER::Types.tree.test( value )
                _internal_map_leaves value, key_path: new_key_path, &block
              else
                block.call new_key_path, value
              end
            }
          }
      end # #_internal_leaves
      
    # end private
    
  end # class << self (Eigenclass)
  
end # module NRSER
