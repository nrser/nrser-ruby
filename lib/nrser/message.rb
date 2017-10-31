# Definitions
# =======================================================================

module NRSER
  
  # Container for a message (method call) to be sent to a receiver via 
  # {Object#send} (or {Object#public_send}).
  # 
  # Encapsulates the method symbol as well as any arguments and block to send.
  # 
  # Implements `#to_a` and `#to_proc` so it can be used like
  # 
  #     obj.send *msg, &msg
  # 
  # You can also invert control via {NRSER::Message#send_to}:
  # 
  #     msg.send_to obj
  # 
  # Useful for clearly describing and recognizing data that is meant to be 
  # sent to an object as a method call, especially in testing.
  # 
  class Message
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
    
    
    # Returns the {#symbol} followed by any {#args}, allowing the instance to
    # be "splatted" into {Object.send}.
    # 
    # @example Send with splat
    #   
    #   obj.send *msg, &msg
    # 
    # @return [Array]
    # 
    def to_a
      [symbol, *args]
    end
    
    
    # Returns {#block}, allowing the instance to be `&`'d into {Object.send}.
    # 
    # @example Send with &
    #   
    #   obj.send *msg, &msg
    # 
    # @return [Proc]
    # 
    def to_proc
      block
    end

    
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
    
    def to_s
      "#<NRSER::Message symbol=#{ symbol } args=#{ args } block=#{ block }>"
    end
  end
  
end # module NRSER

