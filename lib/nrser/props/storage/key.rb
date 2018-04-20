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
  
  def initialize immutable:, key_type:, get: :[], put: :[]=
    @immutable = !!immutable
    @key_type = key_type
    @get_method_name = get
    @put_method_name = put
  end
  
  # Instance Methods
  # ======================================================================
  
  def immutable?
    @immutable
  end
  
  
  def key_for prop
    case @key_type
    when :name
      prop.name
    when :index
      prop.index
    end
  end
  
  
  def get instance, prop
    instance.send @get_method_name, key_for( prop )
  end
  
  
  def put instance, prop, value
    key = key_for prop
    
    if immutable?
      raise RuntimeError.new binding.erb <<~END
        Properties of #{ instance.class.safe_name } are immutable.
        
        Tried to set key
        
            <%= key.pretty_inspect %>
        
        to value
        
            <%= value.pretty_inspect %>
        
        in instance
        
            <%= instance.pretty_inspect %>
        
      END
    end
    
    instance.send @put_method_name, key, value
  end
  
end # class NRSER::Props::Storage::Key
