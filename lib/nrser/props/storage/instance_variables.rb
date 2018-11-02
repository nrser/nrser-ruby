# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/runtime_error'


# Namespace
# ========================================================================

module  NRSER
module  Props
module  Storage


# Definitions
# =======================================================================

# @todo document NRSER::Props::Storage::Key module.
class InstanceVariables
  
  def initialize immutable:
    @immutable = !!immutable
  end
  
  
  def immutable?
    @immutable
  end
  
  
  def get instance, prop
    instance.instance_variable_get "@#{ prop.name }"
  end
  
  
  def put instance, prop, value
    if immutable?
      raise NRSER::RuntimeError.new \
        "Properties of", instance.class,  "are immutable.",
        prop_name: prop.full_name,
        value: value,
        instance: instance
    end
    
    instance.instance_variable_set "@#{ prop.name }", value
  end
  
end # class InstanceVariables


# /Namespace
# ========================================================================

end # module  Storage
end # module  Props
end # module  NRSER

