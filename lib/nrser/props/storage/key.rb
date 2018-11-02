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
class Key
  
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
      raise NRSER::RuntimeError.new \
        "Properties of", instance.class,  "are immutable.",
        prop_name: prop.full_name,
        key: key,
        value: value,
        instance: instance
    end
    
    instance.send @put_method_name, key, value
  end
  
end # class Key


# /Namespace
# ========================================================================

end # module  Storage
end # module  Props
end # module  NRSER
