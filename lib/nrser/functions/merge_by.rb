

module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # @todo Document merge_by method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def merge_by current, *updates, &getter
      updates.reduce( to_h_by current, &getter ) { |result, update|
        deep_merge! result, to_h_by(update, &getter)
      }.values
    end # #merge_by
    
  end # class << self (Eigenclass)
    
end # module NRSER
