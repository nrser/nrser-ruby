# Extension methods for {Module}
# 
# @note
#   These **must not** conflict with function names, which are of course
#   also module methods on the {NRSER} module, because they will override
#   them and prevent access to the functions.
#   
#   Hence the target functions have been prefixed with `f_`.
# 
class Module

  # Calls {NRSER.class_method_objects_for} with `self` as first arg.
  def class_method_objects *args
    NRSER.class_method_objects_for self, *args
  end
  
  alias_method :class_Methods, :class_method_objects
  
  
  # Calls {NRSER.own_class_method_objects_for} with `self` as first arg.
  def own_class_method_objects *args
    NRSER.own_class_method_objects_for self, *args
  end
  
  alias_method :own_class_Methods, :own_class_method_objects
  
  
  # Calls {NRSER.instance_method_objects_for} with `self` as first arg.
  def instance_method_objects *args
    NRSER.instance_method_objects_for self, *args
  end
  
  alias_method :instance_Methods, :instance_method_objects
  
  
  # Calls {NRSER.own_instance_method_objects_for} with `self` as first arg.
  def own_instance_method_objects *args
    NRSER.own_instance_method_objects_for self, *args
  end
  
  alias_method :own_instance_Methods, :own_instance_method_objects
  
  
  # Calls {NRSER.class_method_source_locations_for} with `self` as the
  # first arg.
  def class_method_source_locations *args
    NRSER.class_method_source_locations_for self, *args
  end
  
  
  # Calls {NRSER.class_method_source_locations_for} with `self` as the
  # first arg.
  def own_class_method_source_locations *args
    NRSER.own_class_method_source_locations_for self, *args
  end
  
  # @!endgroup Module Methods
  
end # class Module
