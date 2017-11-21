# Definitions
# =======================================================================

module NRSER
  
  # Container for a message (method call) to be sent to a receiver via 
  # {Object#send} (or {Object#public_send}).
  # 
  # Encapsulates the method symbol as well as any arguments and block to send.
  # 
  # Implements `#to_proc` so it can be used like
  # 
  #     enum.map &message
  # 
  # You can invoke the message on a receiver object like
  # 
  #     msg.send_to obj
  # 
  # Useful for clearly describing and recognizing data that is meant to be 
  # sent to an object as a method call, especially in testing.
  # 
  class Message
    # Class Methods
    # =====================================================================
    
    # Instantiate a message from the arguments, unless they already are one.
    # 
    # @overload from symbol, *args, &block
    #   Create a new instance from the arguments by passing them to 
    #   {NRSER::Message.new}.
    # 
    #   @param [NRSER::Message] message
    #     An already instantiated message, which is simple returned.
    #   
    #   @return [NRSER::Message]
    #     Message created from the arguments.
    # 
    # @overload from message
    #   Convenience method to return the message if it's the only argument.
    #   
    #   @param [NRSER::Message] message
    #     An already instantiated message, which is simple returned.
    #   
    #   @return [NRSER::Message]
    #     The `message` argument.
    # 
    def self.from *args, &block
      if args.length == 1 && args[0].is_a?( Message )
        args[0]
      else
        new *args, &block
      end
    end # .from
    
    
    # Name of method the message is for.
    # 
    # @return [Symbol | String]
    #     
    attr_reader :symbol


    # Arguments (parameters). May be empty.
    # 
    # @return [Array]
    #     
    attr_reader :args


    # Optional block to send to the receiver.
    # 
    # @return [nil | #call]
    #     
    attr_reader :block
    
    
    # Construct a new message.
    # 
    # @param [String | Symbol] symbol
    #   Name of target method.
    # 
    # @param [Array] *args
    #   Any arguments that should be sent.
    # 
    # @param [nil | #call] &block
    #   Optional block that should be sent.
    # 
    def initialize symbol, *args, &block
      @symbol = symbol
      @args = args
      @block = block
    end
    
    
    # Creates a {Proc} that accepts a single `receiver` argument and calls
    # {#sent_to} on it, allowing messages to be used via the `&` operator
    # in `map`, etc.
    # 
    # @example Map each entry as the message receiver using `&`
    #   
    #   enum = [ [], [1], [1, 2] ]
    #   
    #   length_message = NRSER::Message.new :length
    #   first_message = NRSER::Message.new :first
    #   
    #   enum.map &length_message
    #   # => [0, 1, 2]
    #   
    #   enum.map &first_message
    #   # => [nil, 1, 1]
    # 
    # @return [Proc]
    # 
    def to_proc publicly: true
      # block
      ->( receiver ) { send_to receiver, publicly: publicly }
    end
    
    alias_method :to_sender, :to_proc

    
    # Send this instance to a receiver object.
    # 
    # @example
    #   
    #   msg.send_to obj
    # 
    # @param [Object] receiver
    #   Object that the message will be sent to.
    # 
    # @param [Boolean] publicly:
    #   When `true`, the message will be sent via {Object#public_send}. This is
    #   the default behavior.
    #   
    #   When `false`, the message will be sent via {Object#send}, allowing it
    #   to invoke private and protected methods on the receiver.
    # 
    # @return [Object]
    #   Result of the method call.
    # 
    def send_to receiver, publicly: true
      if publicly
        receiver.public_send symbol, *args, &block
      else
        receiver.send symbol, *args, &block
      end
    end
    
    # @return [String]
    #   Brief description of the message.
    # 
    def to_s
      "#<NRSER::Message symbol=#{ symbol } args=#{ args } block=#{ block }>"
    end
  end # class Message
  
end # module NRSER

