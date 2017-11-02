# Definitions
# =======================================================================

module NRSER
  
  # @todo Document transform method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.transform tree, source
    each_branch( tree ).map { |pair|
      pair.map { |value|
        if NRSER::Types.tree.test value
          transform value, source
        else
          if value.is_a? Proc
            value.call source
          else
            value
          end
        end
      }
    }.to_h
  end # .transform
  
    
end # module NRSER
