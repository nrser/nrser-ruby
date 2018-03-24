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

module NRSER::Props::Storage; end


# Definitions
# =======================================================================

# @todo document NRSER::Props::Storage::Key module.
class NRSER::Props::Storage::InstanceVariables
  
  def initialize immutable:
    @immutable = !!immutable
  end
  
  
  def immutable?
    @immutable
  end
  
  
  def get instance, key
    instance.instance_variable_get "@#{ key }"
  end
  
  
  def put instance, key, value
    if immutable?
      raise RuntimeError.new binding.erb <<~END
        Properties of #{ instance.class.name } are immutable.
        
        Tried to set key
        
            <%= key.pretty_inspect %>
        
        to value
        
            <%= value.pretty_inspect %>
        
        in instance
        
            <%= instance.pretty_inspect %>
        
      END
    end
    
    instance.instance_variable_set "@#{ key }", value
  end
  
end
