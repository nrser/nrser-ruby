# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Declarations
# =======================================================================


# Definitions
# =======================================================================

class Object
  
  # @todo Document lazy_instance_var method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def lazy_var name, &getter
    unless instance_variable_defined? name
      instance_variable_set name, getter.call
    end
    
    instance_variable_get name
  end # #lazy_instance_var
end
