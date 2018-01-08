##
# Methods that make useful {Proc} instances.
## 

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative '../message'


# Definitions
# =======================================================================

module NRSER
  
  # Creates a new {NRSER::Message} from the array.
  # 
  # @example
  #   
  #   message = NRSER::Op.message( :fetch, :x )
  #   message.send_to x: 'ex', y: 'why?'
  #   # => 'ex'
  # 
  # @return [NRSER::Message]
  # 
  def self.message *args, &block
    if args.length == 1 && args[0].is_a?( Message )
      args[0]
    else
      Message.new *args, &block
    end
  end # #message
  
  singleton_class.send :alias_method, :msg, :message
  
  
  # Create a {Proc} that sends the arguments to a receiver via `#public_send`.
  # 
  # Equivalent to
  # 
  #     message( symbol, *args, &block ).to_proc
  # 
  # Pretty much here for completeness' sake.
  # 
  # @example
  #   
  #   sender( :fetch, :x ).call x: 'ex'
  #   # => 'ex'
  # 
  # @return [Proc]
  # 
  def self.public_sender symbol, *args, &block
    message( symbol, *args, &block ).to_proc
  end # .public_sender
  
  singleton_class.send :alias_method, :sender, :public_sender
  singleton_class.send :alias_method, :sndr, :public_sender
  
  
  # Create a {Proc} that sends the arguments to a receiver via `#send`,
  # forcing access to private and protected methods.
  # 
  # Equivalent to
  # 
  #     message( symbol, *args, &block ).to_proc publicly: false
  # 
  # Pretty much here for completeness' sake.
  # 
  # @example
  #   
  #   sender( :fetch, :x ).call x: 'ex'
  #   # => 'ex'
  # 
  # @return [Proc]
  # 
  def self.private_sender symbol, *args, &block
    message( symbol, *args, &block ).to_proc publicly: false
  end # .private_sender
  
  
  # Map *each entry* in `mappable` to a {NRSER::Message} and return a
  # {Proc} that accepts a single `receiver` argument and reduces it by
  # applying each message in turn.
  # 
  # In less precise terms: create a proc that chains the entries as
  # methods calls.
  # 
  # @note
  #   `mappable`` entries are mapped into messages when {#to_chain} is called,
  #   meaning subsequent changes to `mappable` **will not** affect the
  #   returned proc.
  # 
  # @example Equivalent of `Time.now.to_i`
  # 
  #   NRSER::chainer( [:now, :to_i] ).call Time
  #   # => 1509628038
  # 
  # @return [Proc]
  # 
  def self.chainer mappable, publicly: true
    messages = mappable.map { |value| message *value }
    
    ->( receiver ) {
      messages.reduce( receiver ) { |receiver, message|
        message.send_to receiver, publicly: publicly
      }
    }
  end # .chainer
  
  singleton_class.send :alias_method, :chnr, :chainer
  
  
  # Return a {Proc} that accepts a single argument that must respond to `#[]`
  # and retrieves `key` from it.
  # 
  # @param [String | Symbol | Integer] key
  #   Key (or index) to retrieve.
  # 
  # @return [Proc]
  # 
  def self.retriever key
    ->( indexed ) { indexed[key] }
  end # .getter
  
  singleton_class.send :alias_method, :rtvr, :retriever
  
  
end # module NRSER
