# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './enumerable'
require_relative './tree'


# Definitions
# =======================================================================

module NRSER
  refine ::Array do
    include NRSER::Refinements::Enumerable
    include NRSER::Refinements::Tree
    
    
    # @return [Array]
    #   new array consisting of all elements after the first (which may be 
    #   none, resulting in an empty array).
    # 
    def rest
      NRSER.rest self
    end # #rest
    
    
    # `to_*` Converters
    # =====================================================================
    
    # Checks that length is 2 and returns `self`.
    # 
    # @return [Array]
    #   Array of length 2.
    # 
    # @raise [TypeError]
    #   If length is not 2.
    # 
    def to_pair
      unless length == 2
        raise TypeError,
              "Array is not of length 2: #{ self.inspect }"
      end
      
      self
    end # #to_pair
    
    
    # To Operation Objects
    # ---------------------------------------------------------------------
    
    # Creates a new {NRSER::Message} from the array.
    # 
    # @example
    #   
    #   message = [:fetch, :x].to_message
    #   message.send_to x: 'ex', y: 'why?'
    #   # => 'ex'
    # 
    # @return [NRSER::Message]
    # 
    def to_message
      NRSER::Message.new *self
    end # #to_message
    
    alias_method :to_m, :to_message
    
    
    # Create a unary {Proc} that accepts a `receiver` and provides this array's
    # entries as the arguments to `#public_send` (or `#send` if the `publicly`
    # option is `false`).
    # 
    # @example
    #   
    #   sender = [:fetch, :x].to_sender
    #   sender.call x: 'ex'
    #   # => 'ex'
    # 
    # @param [Boolean] publicly:
    #   See {NRSER::Message#sent_to}.
    # 
    # @return [Proc]
    # 
    def to_sender publicly: true
      to_message.to_proc publicly: publicly
    end
    
    
    # Returns a lambda that calls accepts a single arg and calls `#dig` on it
    # with the elements of *this* array as arguments.
    # 
    # @example
    #   list = [{id: 1, name: "Neil"}, {id: 2, name: "Mica"}]
    #   list.to_h_by &[:id].digger
    #   # =>  {
    #   #       1 => {id: 1, name: "Neil"},
    #   #       2 => {id: 2, name: "Mica"},
    #   #     }
    # 
    # @todo
    #   I wanted to use `#to_proc` so that you could use `&[:id]`, but unary
    #   `&` doesn't invoke refinements, and I don't really want to monkey-patch
    #   anything, especially something as core as `#to_proc` and `Array`.
    # 
    # @return [Proc]
    #   Lambda proc that accepts a single argument and calls `#dig` with this 
    #   array's contents as the `#dig` arguments.
    # 
    def to_digger
      NRSER::Message.new( :dig, *self ).to_proc
    end # #to_digger
    
    # Old (or alternate?) name
    alias_method :digger, :to_digger
    
    
  end # refine ::Array
end # NRSER