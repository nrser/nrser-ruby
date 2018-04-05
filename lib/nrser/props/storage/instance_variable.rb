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
class NRSER::Props::Storage::InstanceVariable
  
  DEFAULT_VAR_NAME = :@__NRSER_prop_values
  
  # TODO document `var_name` attribute.
  # 
  # @return [Symbol]
  #     
  attr_reader :var_name
  
  
  # TODO document `sub_storage` attribute.
  # 
  # @return [attr_type]
  #     
  attr_reader :sub_storage
  
  
  def initialize  var_name: DEFAULT_VAR_NAME,
                  sub_storage:
    @var_name = var_name.to_sym
    @sub_storage = sub_storage
  end
  
  # Instance Methods
  # ======================================================================
  
  
  def init instance, collection
    if init? instance
      raise NRSER::ConflictError.new binding.erb <<~END
        Already initialized!
        
        Instance:
        
            <%= instance.pretty_inspect %>
        
        Collection:
        
            <%= collection.pretty_inspect %>
        
      END
    end
    
    instance.instance_variable_set @var_name, collection
  end
  
  
  def init? instance
    instance.instance_variable_defined? @var_name
  end
  
  
  def get instance, prop
    sub_storage.get instance.instance_variable_get( @var_name ), prop
  end
  
  
  def put instance, prop, value
    sub_storage.put \
      instance.instance_variable_get( @var_name ),
      prop,
      value
  end
  
end
