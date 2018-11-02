# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/conflict_error'


# Namespace
# ========================================================================

module  NRSER
module  Props
module  Storage


# Definitions
# =======================================================================

# @todo document NRSER::Props::Storage::Key module.
class InstanceVariable
  
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
      raise NRSER::ConflictError.new \
        "Already initialized!",
        instance: instance,
        collection: collection
    end
    
    instance.instance_variable_set @var_name, collection
  end
  
  
  def immutable?
    sub_storage.immutable?
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
  
end # class InstanceVariable


# /Namespace
# ========================================================================

end # module  Storage
end # module  Props
end # module  NRSER
