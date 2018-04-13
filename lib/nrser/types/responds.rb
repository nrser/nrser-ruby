require 'nrser/message'
require_relative './booleans'

module NRSER::Types
  
  # Type holding an {NRSER::Message} and response type. Satisfied by objects
  # that respond with a value that satisfies the respond type when sent the
  # message.
  # 
  class Respond < NRSER::Types::Type
    
    # Attributes
    # ======================================================================
    
    # Message that will be sent to tested values.
    # 
    # @return [NRSER::Message]
    #     
    attr_reader :message
    
    
    # Type tested values must respond with when sent the message.
    # 
    # @return [NRSER::Types::Type]
    #     
    attr_reader :response
    
    
    
    # TODO document `publicly` attribute.
    # 
    # @return [Boolean]
    #     
    attr_reader :publicly
    
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `Respond`.
    def initialize  to:,
                    with:,
                    publicly: true,
                    **options
      @message = NRSER::Message.from *to
      @publicly = publicly
      @response = NRSER::Types.make with
      
      super **options
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    # See {NRSER::Types::Type#explain}.
    # 
    # @param  (see NRSER::Types::Type#explain)
    # @return (see NRSER::Types::Type#explain)
    # @raise  (see NRSER::Types::Type#explain)
    # 
    def explain
      args_str = message.args.map( &:inspect ).join ', '
      
      if message.block
        args_str += ', ' + message.block.to_s
      end
      
      "##{ message.symbol }(#{ args_str })#{ RESPONDS_WITH }#{ response.explain }"
    end
    
    
    # Test value for membership.
    # 
    # @param  (see NRSER::Types::Type#test?)
    # @return (see NRSER::Types::Type#test?)
    # @raise  (see NRSER::Types::Type#test?)
    # 
    def test? value
      response.test message.send_to( value, publicly: publicly )
    end # #test
    
  end # class Responds
  

  def_factory(
    :respond,
  ) do |*args|
    Respond.new *args
  end # #responds
  
  
  def_factory(
    :respond_to
  ) do |method_name, **options|
    respond to: [:respond_to?, method_name], with: NRSER::Types.true
  end # #respond_to
  
end # module NRSER::Types
