# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Object
  
  # If the instance variable `name` is not defined, sets it to the result
  # of `&block`. Always returns the instance variable's value.
  # 
  # Useful for lazy values that can be `nil` or `false`, since `||=` will
  # always re-evaluate in their cases.
  # 
  # @param [Symbol] name
  #   The name of the instance variable. Needs to have that `@` on the
  #   front, like `:@x`.
  # 
  # @param [Proc<() => VALUE>] block
  #   The block to call to get the value.
  # 
  # @return [VALUE]
  #   The value of the instance variable.
  # 
  def lazy_var name, &block
    unless instance_variable_defined? name
      instance_variable_set name, block.call
    end
    
    instance_variable_get name
  end # #lazy_instance_var
  
end


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
