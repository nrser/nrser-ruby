require_relative './booleans'

module NRSER::Types
  
  # Type that encodes messages mapped to result types that member values must
  # satisfy.
  class Responds < NRSER::Types::Type
    
    # Constants
    # ======================================================================
    
    
    # Class Methods
    # ======================================================================
    
    
    # Attributes
    # ======================================================================
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `Responds`.
    def initialize  map,
                    public: true,
                    **options
      @map = map.transform_values { |type| NRSER::Types.make type }
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    
    def default_name
      attrs_str = @map.map { |args, type|
        args_str = args[1..-1].map(&:inspect).join ', '
        "#{ args[0] }(#{ args_str })=#{ type.name }"
      }.join(', ')
      
      "#{ self.class.demod_name } #{ attrs_str }"
    end
    
    
    # @todo Document test method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def test? value
      @map.all? { |args, type|
        response = if @public
          value.public_send *args
        else
          value.send *args
        end
        
        type.test response
      }
    end # #test
    
    
  end # class Responds
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    
    # @todo Document responds method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def responds *args
      Responds.new *args
    end # #responds
    
    
    # @todo Document respond_to Responds.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def respond_to name, **options
      responds(
        {[:respond_to?, name] => NRSER::Types.true},
        **options
      )
    end # #respond_to
    
    
  end # class << self (Eigenclass)
  
  
end # module NRSER::Types
