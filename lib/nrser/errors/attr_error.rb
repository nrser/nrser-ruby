# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

require_relative './value_error'


# Namespace
# ========================================================================

module  NRSER


# Raised when we expected `#count` to be something it's not.
# 
# Extends {NRSER::ValueError}, and the {#value} must be the instance that
# 
class AttrError < ValueError

  # @!method name?
  #   Is there an `:name` key in {#context}?
  #   
  #   @return [Boolean]
  # 
  # @!method name
  #   Name of attribute that has invalid value, which can be provided via
  #   the `:name` key in the {#context}.
  #   
  #   @return [Symbol | String]
  # 
  def_context_delegator keys: :name


  # @!method expected?
  #   Is there an `:expected` key in {#context}?
  #   
  #   @return [Boolean]
  #   
  # @!method expected
  #   Optional information about what the attribute value was expected to be,
  #   which can be provided via the `:expected` key in {#context}.
  #   
  #   @return [Object]
  # 
  def_context_delegator keys: :expected


  # @!method initialize *message, **kwds
  #   Create a new {AttrError}.
  #   
  #   This method does nothing but call `super`. It's here only for doc's sake.
  #   
  #   @note
  #     If you provide the `:name` and `:value` keyword arguments, but *not* 
  #     `:actual` then {#actual} will attempt to retrieve the attribute's value
  #     by
  #     
  #         value.public_send name
  #     
  #     This really *shouldn't* be problematic - if attempting to access a public
  #     attribute can cause serious side-effects, you may want to re-think your
  #     design. However, I still felt like I should note it here.
  #     
  #     The call is wrapped in a `rescue StandardError`, so you **don't** need
  #     to worry about anything mundane like an error being raised.
  #   
  #   @param [Array] message
  #     See {NicerError#initialize}.
  #   
  #   @param [Hash<Symbol, Object>] kwds
  #     Except as called out below, other keywords are passed up to 
  #     {NicerError#initialize}.
  #   
  #   @option kwds [Symbol | String] :name
  #     The name of the attribute in question.
  #   
  #   @option kwds [Object] :value
  #     The value that has the bad attribute.
  #   
  #   @option kwds [Object | NRSER::Types::Type | String] :expected
  #     Encouraged to be one of:
  #     
  #     1.  The {Object} you wanted the attribute to respond with.
  #         
  #     2.  A {NRSER::Types::Type} satisfied by what you would have been satisfied
  #         with.
  #         
  #     3.  A {String} explanation of the condition.
  #   
  #   @option kwds [Object] :actual
  #     The actual attribute value.
  #     


  # Tests if an 'actual' value was provided in the {#context}.
  # 
  # @return [Boolean]
  # 
  def actual?
    context.key?( :actual ) || ( value? && name? && value.respond_to?( name ) )
  rescue StandardError => error
    false
  end


  # Get an optional actual value for the attribute, from `context[:actual]`
  # if it exists or by sending {#name} to {#value} if it works.
  # 
  # @return [nil]
  #   If {#context} does not have an `:actual` value and {#value} raises
  #   a {StandardError}.
  # 
  # @return [Object]
  #   The value of {#context}'s `:actual` key, if any, otherwise {#value}'s
  #   response to {#name}.
  # 
  def actual
    if context.key? :actual
      context[ :actual ]
    elsif value? && name?
      value.public_send name
    end
  rescue StandardError => error
    nil
  end

  
  # Create a default message if none was provided.
  # 
  # Uses whatever recognized {#context} values are present, falling back
  # to {NicerError#default_message} if none are.
  # 
  # @return [String]
  # 
  def default_message
    message = []

    if value? && name?
      message << format_message(  value.class, "object", value.inspect,
                                  "has invalid ##{ name } attribute" )
    end

    if expected?
      message << format_message( "expected", expected )
    end

    if actual?
      message << format_message( "found", actual )
    end

    if message.empty?
      super
    else
      message.join ', '
    end
  end
  
end # class AttrError


# /Namespace
# ========================================================================

end # module NRSER
