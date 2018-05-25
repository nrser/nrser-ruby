# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

require 'method_decorators'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# Store the result of an attribute method (no args) in an instance variable
# of the same name and return that value on subsequent calls.
# 
class LazyAttr < MethodDecorators::Decorator
  
  # Get the instance variable name for a target method.
  # 
  # @param [Method] target_method
  #   The method the decorator is decorating.
  # 
  # @return [String]
  #   The name of the instance variable, ready to be provided to
  #   `#instance_variable_set` (has `@` prefix).
  # 
  def self.instance_var_name target_method
    name = target_method.name.to_s
    
    # Allow predicate methods by chopping off the `?` character.
    # 
    # Other stupid uses like `+` or whatever will raise when
    # `#instance_variable_set` is called.
    # 
    name = name[0..-2] if name.end_with? '?'
    
    "@#{ name }"
  end # .instance_var_name
  
  
  # Execute the decorator.
  # 
  # @param [Method] target_method
  #   The decorated method, already bound to the receiver.
  #   
  #   The `method_decorators` gem calls this `orig`, but I thought
  #   `target_method` made more sense.
  # 
  # @param [*] receiver
  #   The object that will receive the call to `target`.
  #   
  #   The `method_decorators` gem calls this `this`, but I thought `receiver`
  #   made more sense.
  #   
  #   It's just `target.receiver`, but the API is how it is.
  # 
  # @param [Array] *args
  #   Any arguments the decorated method was called with.
  # 
  # @param [Proc?] &block
  #   The block the decorated method was called with (if any).
  # 
  # @return
  #   Whatever `target_method` returns.
  # 
  def call target_method, receiver, *args, &block
    unless target_method.parameters.empty?
      raise NRSER::ArgumentError.new \
        "{NRSER::LazyAttr} can only decorate methods with 0 params",
        receiver: receiver,
        target_method: target_method
    end
    
    unless args.empty?
      raise NRSER::ArgumentError.new \
        "wrong number of arguments for", target_method,
        "(given", args.length, "expected 0)",
        receiver: receiver,
        target_method: target_method
    end
    
    unless block.nil?
      raise NRSER::ArgumentError.new \
        "wrong number of arguments (given #{ args.length }, expected 0)",
        receiver: receiver,
        target_method: target_method
    end
    
    var_name = self.class.instance_var_name target_method
    
    unless receiver.instance_variable_defined? var_name
      receiver.instance_variable_set var_name, target_method.call
    end
      
    receiver.instance_variable_get var_name
        
  end # #call
  
end # class LazyAttr


# /Namespace
# =======================================================================

end # module NRSER
