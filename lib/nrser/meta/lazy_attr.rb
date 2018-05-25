# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

require 'method_decorators'

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# @todo document LazyAttr class.
class LazyAttr < MethodDecorators::Decorator
  
  
  # @todo Document instance_var_name method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
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
  
  
  # @todo Document call method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
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
