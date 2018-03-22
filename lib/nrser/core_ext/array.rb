class Array
  include NRSER::Ext::Tree
  
  
  # @return [Array]
  #   new array consisting of all elements after the first (which may be
  #   none, resulting in an empty array).
  # 
  def rest
    NRSER.rest self
  end # #rest
  
  
  def extract! &block
    NRSER.extract_from_array! self, &block
  end
  
  
  # Calls {NRSER.ellipsis} on `self`.
  def ellipsis *args
    NRSER.ellipsis self, *args
  end
  
  
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
  
  
  # Create a {Proc} that accepts a single `receiver` and provides this array's
  # entries as the arguments to `#public_send` (or `#send` if the `publicly`
  # option is `false`).
  # 
  # Equivalent to
  # 
  #   to_message.to_proc publicly: boolean
  # 
  # @example
  #   
  #   [:fetch, :x].sender.call x: 'ex'
  #   # => 'ex'
  # 
  # @param [Boolean] publicly:
  #   When `true`, uses `#public_send` in liu of `#send`.
  # 
  # @return [Proc]
  # 
  def to_sender publicly: true
    to_message.to_proc publicly: publicly
  end
  
  
  # See {NRSER.chainer}.
  #
  def to_chainer publicly: true
    NRSER.chainer self, publicly: publicly
  end # #to_chainer
  
  
  # Returns a lambda that calls accepts a single arg and calls `#dig` on it
  # with the elements of *this* array as arguments.
  # 
  # @example
  #   list = [{id: 1, name: "Neil"}, {id: 2, name: "Mica"}]
  #   list.assoc_by &[:id].to_digger
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

end # class Array
