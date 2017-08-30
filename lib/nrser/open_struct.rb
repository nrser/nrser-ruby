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
    def to_open_struct hash, freeze: false
      unless hash.is_a? Hash
        raise TypeError,
              "Argument must be hash (found #{ hash.inspect })"
      end
      
      _to_open_struct hash, freeze: freeze
    end # #to_open_struct
    
    
    private
    
      def _to_open_struct value, freeze:
        result = case value
        when OpenStruct
          # Just assume it's already taken care of if it's already an OpenStruct
          value
          
        when Hash
          OpenStruct.new(
            map_values(value) { |k, v| _to_open_struct v, freeze: freeze }
          )
          
        when Array
          value.map { |v| _to_open_struct v, freeze: freeze }
          
        when Set
          Set.new value.map { |v| _to_open_struct v, freeze: freeze }
        
        else
          value
        end
        
        if freeze
          result.freeze
        end
        
        result
      end # ._to_open_struct
    # end private
    
  end # class < self (Eigenclass)
  
end # module NRSER
