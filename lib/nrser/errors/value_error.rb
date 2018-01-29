# frozen_string_literal: true


# Raised when there is a problem with a *value* that does not fall into one
# of the other built-in exception categories (non-exhaustive list):
# 
# 1.  It's the wrong type (TypeError)
# 2.  It's an argument (ArgumentError)
# 
# The invalid value is attached to the error as an instance value so that
# rescuers up the stack can do more intelligent things with it if need be.
# 
class NRSER::ValueError < StandardError
  
  # The invalid value.
  # 
  # @return [Object]
  #     
  attr_reader :subject
  
  
  def initialize message = nil, subject:
    @subject = subject
    
    # If we received `nil` for the message, call {#build_message} to get it.
    # 
    # This provides a "hook" to assemble the message at the last possible
    # moment before it needs to go up to {StandardError#initialize}, allowing
    # {#build_message} to work with an otherwise fully-initialized instance.
    # 
    # Of course, {NRSER::ValueError#build_message}
    # throws {NotImplementedError} since it doesn't really have enough
    # knowledge to build anything useful (we're going for useful errors,
    # "Value #{ value } is invalid" does not suffice).
    # 
    message = build_message if message.nil?
    
    super message
  end
  
  
  # Build the error message when none is provided to `#initialize`.
  # 
  # When no `message` (or `nil`) is provided to {NRSER::ValueError.initialize}
  # it will call this method to get the error message just before it needs it
  # to call up to {StandardError#initialize} (via `super message`).
  # 
  # This allows {NRSER::ValueError} subclasses that are able to build a useful
  # default message or would like to augment the user-provided one to do so
  # at the last possible moment before it's needed, letting them work with an
  # otherwise fully-initialized instance.
  # 
  # Hence a subclass several generations down from {NRSER::ValueError} can
  # use values initialized in all the constructors in-between, avoiding a lot
  # of headache.
  # 
  # This implementation always raises {NRSER::AbstractMethodError} because
  # {NRSER::ValueError} does not have enough information to construct a useful
  # message.
  # 
  # @return [String]
  #   Implementations must return the message string for
  #   {StadardError#initialize}.
  # 
  # @raise [NRSER::AbstractMethodError]
  #   Must be implemented by subclasses if they wish to use message building.
  # 
  def build_message
    raise NRSER::AbstractMethodError.new( self, __method__ )
  end
  
end
