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
  
  
  def get instance, prop
    instance.instance_variable_get "@#{ prop.name }"
  end
  
  
  def put instance, prop, value
    if immutable?
      raise RuntimeError.new binding.erb <<~END
        Properties of #{ instance.class.safe_name } are immutable.
        
        Tried to set prop #{ prop.name } to value
        
            <%= value.pretty_inspect %>
        
        in instance
        
            <%= instance.pretty_inspect %>
        
      END
    end
    
    instance.instance_variable_set "@#{ prop.name }", value
  end
  
end
