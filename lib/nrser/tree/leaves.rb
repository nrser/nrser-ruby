module NRSER
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # Create a new hash where all the values are the scalar "leaves" of the 
    # possibly nested `hash` param. Leaves are keyed by "key path" arrays 
    # representing the sequence of keys to dig that leaf out of the has param.
    # 
    # In abstract, if `h` is the `hash` param and
    # 
    #     l = NRSER.leaves h
    # 
    # then for each key `k` and corresponding value `v` in `l`
    # 
    #     h.dig( *k ) == v
    # 
    # @example Simple "flat" hash
    #   
    #   NRSER.leaves( {a: 1, b: 2} )
    #   => {
    #     [:a] => 1,
    #     [:b] => 2,
    #   }
    # 
    # @example Nested hash
    #   
    #   NRSER.leaves(
    #     1 => {
    #       name: 'Neil',
    #       fav_color: 'blue',
    #     },
    #     2 => {
    #       name: 'Mica',
    #       fav_color: 'red',  
    #     }
    #   )
    #   # => {
    #   #   [1, :name]      => 'Neil',
    #   #   [1, :fav_color] => 'blue',
    #   #   [2, :name]      => 'Mica',
    #   #   [2, :fav_color] => 'red',
    #   # }
    #   
    # @param [#each_pair | (#each_index & #each_with_index)] tree
    #   
    # 
    def leaves tree
      {}.tap { |results|
        _internal_leaves tree, path: [], results: results
      }
    end # #leaves
    
    
    private
    # ========================================================================
      
      # @todo Document _internal_leaves method.
      # 
      # @param [type] arg_name
      #   @todo Add name param description.
      # 
      # @return [return_type]
      #   @todo Document return value.
      # 
      def _internal_leaves tree, path:, results:
        NRSER.each_branch( tree ) { |key, value|
          new_path = [*path, key]
          
          if tree? value
            _internal_leaves value, path: new_path, results: results
          else
            results[new_path] = value
          end
        }
        
        nil
      end # #_internal_leaves
      
    # end private
    
  end # class << self (Eigenclass)
  
end # module NRSER
