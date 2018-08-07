# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/message'
require_relative './booleans'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# This {Type} is used to test how the values in question respond to specific
# messages (method calls).
# 
# {Respond} instances hold a {#message} and {#response} type. Instances
# that respond when sent the message with a value that satisfies the 
# response type are members.
# 
# @example Type whose members have non-empty string names.
#   type =  Types:Respond.new \
#             to: :name,
#             with: Types.non_empty_str
# 
class Respond < Type
  
  # Attributes
  # ======================================================================
  
  # Message that will be sent to tested values.
  # 
  # @return [NRSER::Message]
  #     
  attr_reader :message
  
  
  # Type tested values must respond with when sent the message.
  # 
  # @return [Type]
  #     
  attr_reader :response
  
  
  # Controls whether the {#message} will be sent using `#public_send` (the
  # default) or `#send` - which has access to private and protected 
  # methods.
  #
  # @return [Boolean]
  #
  attr_reader :publicly
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new instance.
  # 
  # See construction example in the class header: {Respond}.
  # 
  # @param [String | Symbol | Array] to
  #   Fed in to {NRSER::Message.from} to create the {#message}.
  #   
  #   Must be a lone string or symbol representing the method name to call,
  #   or an Array with the string or symbol methods name in the first entry
  #   (and whatever other parameters can follow it).
  # 
  # @param [Type | Object] with
  #   The type members must respond with. If `with:` is not a {Type} it will
  #   be made into on via {Types.make}.
  # 
  # @param [Boolean] publicly
  #   Chooses between using `#public_send` and `#send` to send the {#message}.
  # 
  # @param [Hash] options
  #   Additional options that will be passed up to {Type#initialize}.
  # 
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
  
  # See {Type#explain}.
  # 
  # @param  (see Type#explain)
  # @return (see Type#explain)
  # @raise  (see Type#explain)
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
  # @param  (see Type#test?)
  # @return (see Type#test?)
  # @raise  (see Type#test?)
  # 
  def test? value
    response.test message.send_to( value, publicly: publicly )
  end # #test
  
end # class Responds


# Factories
# ----------------------------------------------------------------------------

# @!group Method Response Type Factories
# ----------------------------------------------------------------------------

#@!method self.Respond to:, with:, publicly: true, **options
#   Create a {Respond} type.
#   
#   @param (see Respond#initialize)
#   
#   @return [Respond]
#   
def_type        :Respond,
  default_name: false,
  parameterize: [ :to, :with, :publicly ],
&->( to:, with:, publicly: true, **options ) do
  Respond.new to: to, with: with, publicly: publicly, **options
end # .Respond


#@!method self.RespondTo method_name, **options
#   Gets a {Respond} that admits values that `#respond_to?` a `method_name`.
#   
#   @param [Symbol | String] method_name
#     The name of the method that type members must `#respond_to?`.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Respond]
#   
def_type        :RespondTo,
  default_name: ->( method_name, **options ) {
                  "RespondTo<#{ method_name }>"
                },
  parameterize: :method_name,
  # TODO  I'm not sure how this worked before, but defining `.respond_to?` 
  #       def fucks things up...
  # maybe:        false,
&->( method_name, **options ) do
  respond to: [:respond_to?, method_name], with: self.True
end # .RespondTo

# @!endgroup Method Response Type Factories # ********************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
