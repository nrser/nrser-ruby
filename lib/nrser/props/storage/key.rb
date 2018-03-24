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
class NRSER::Props::Storage::Key
  
  def initialize immutable:
    @immutable = !!immutable
  end
  
  # Instance Methods
  # ======================================================================
  
  def immutable?
    @immutable
  end
  
  
  def get instance, key
    instance[key]
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
    
    instance[key] = value
  end
  
end # class NRSER::Props::Storage::Key
