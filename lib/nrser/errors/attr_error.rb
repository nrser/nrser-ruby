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

  # @!method name
  #   Name of attribute that has invalid value.
  #   
  #   @return [Symbol]
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
