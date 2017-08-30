module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # Deeply convert a {Hash} to an {OpenStruct}.
    # 
    # @param [Hash] hash
    # 
    # @return [OpenStruct]
    # 
    # @raise [TypeError]
    #   If `hash` is not a {Hash}.
    # 
    def to_open_struct hash
      unless hash.is_a? Hash
        raise TypeError,
              "Argument must be hash (found #{ hash.inspect })"
      end
      
      _to_open_struct hash
    end # #to_open_struct
    
    private
    
    def _to_open_struct value
      case value
      when OpenStruct
        # Just assume it's already taken care of if it's already an OpenStruct
        value
        
      when Hash
        OpenStruct.new(
          map_values(value) { |k, v| _to_open_struct v }
        )
        
      when Array
        value.map { |v| _to_open_struct v }
        
      when Set
        Set.new value.map { |v| _to_open_struct v }
      
      else
        value
      end
    end
    
  end # class < self (Eigenclass)
  
end # module NRSER
