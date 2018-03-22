module NRSER
    
    # Deeply convert a {Hash} to an {OpenStruct}.
    # 
    # @param [Hash] hash
    # 
    # @return [OpenStruct]
    # 
    # @raise [TypeError]
    #   If `hash` is not a {Hash}.
    # 
    def self.to_open_struct hash, freeze: false
      unless hash.is_a? Hash
        raise TypeError,
              "Argument must be hash (found #{ hash.inspect })"
      end
      
      _to_open_struct hash, freeze: freeze
    end # #to_open_struct
    
  
    def self._to_open_struct value, freeze:
      result = case value
      when OpenStruct
        # Just assume it's already taken care of if it's already an OpenStruct
        value
        
      when Hash
        OpenStruct.new(
          value.transform_values { |v| _to_open_struct v, freeze: freeze }
        )
        
      when Array
        value.map { |v| _to_open_struct v, freeze: freeze }
        
      when Set
        Set.new value.map { |v| _to_open_struct v, freeze: freeze }
      
      else
        value
      end
      
      result.freeze if freeze
      
      result
    end # ._to_open_struct
    
    private_class_method :_to_open_struct
  
end # module NRSER
