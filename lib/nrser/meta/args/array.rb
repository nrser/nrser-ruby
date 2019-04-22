# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

### Project / Package ###

require_relative '../args'


# Namespace
# =======================================================================

module  NRSER
module  Meta
module  Args


# Definitions
# =======================================================================

# Represent method call arguments as an {::Array} that has an additional 
# {#block} member.
# 
class Array < ::Array
  
  # Mixins
  # ==========================================================================
  
  # "Mark" as an {Args}, which is just an interface
  include Args
  
  
  # Attributes
  # ==========================================================================
  
  # Optional block argument.
  # 
  # @return [nil | ::Proc | #to_proc]
  #     
  attr_accessor :block
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {Args::Array}.
  # 
  def initialize *args, &block
    @block = block
    super( args )
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Calls a `#call`-able (like a {::Proc} or {::Method}), passing its values
  # as the arguments and block.
  # 
  # @param [#call] callable
  #   
  # @return [::Object]
  #   Response to the call.
  # 
  # @raise
  #   If the call raises.
  # 
  def call callable
    callable.call *self, &block
  end
  
end # class Array


# /Namespace
# =======================================================================

end # module  Args
end # module  Meta
end # module  NRSER
