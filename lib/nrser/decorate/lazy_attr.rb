# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Project / Package ###

require 'nrser/decorate'


# Namespace
# =======================================================================

module  NRSER
module  Decorate


# Definitions
# =======================================================================

# Store the result of an attribute method (no args) in an instance variable
# of the same name and return that value on subsequent calls.
# 
class LazyAttr
  
  # Get the instance variable name for a target method.
  # 
  # @param [Method] target_method
  #   The method the decorator is decorating.
  # 
  # @return [String]
  #   The name of the instance variable, ready to be provided to
  #   `#instance_variable_set` (has `@` prefix).
  # 
  def self.instance_var_name target
    name = target.name.to_s
    
    # Allow predicate methods by chopping off the `?` character.
    # 
    # Other stupid uses like `+` or whatever will raise when
    # `#instance_variable_set` is called.
    # 
    name = name[0..-2] if name.end_with? '?'
    
    "@#{ name }"
  end # .instance_var_name
  
  
  def initialize method_ref
    unless method_ref.parameters.empty?
      raise ArgumentError.new \
        "{NRSER::LazyAttr} can only decorate methods with 0 params",
        receiver: target.receiver,
        target: target
    end
    
    @method_ref = method_ref
  end
  
  
  # Execute the decorator.
  # 
  # @param [::Object] receiver
  #   Object that received the call.
  # 
  # @param [::Method] target
  #   The method that constructs the attribute value, which is only called the
  #   first time and cached after that.
  # 
  # @return [::Object]
  #   The attribute value.
  # 
  def call target
    var_name = self.class.instance_var_name target
    
    unless target.receiver.instance_variable_defined? var_name
      target.receiver.instance_variable_set var_name, target.call
    end
      
    target.receiver.instance_variable_get var_name
        
  end # #call
  
end # class LazyAttr


# /Namespace
# =======================================================================

end # module  Decorate
end # module NRSER
