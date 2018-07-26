# Extension methods for {Module}
# 
class Module
  
  # @!group {Method} Object Readers
  # ==========================================================================

  # Get class methods for this {Module} ({Class} are also {Module}, so works
  # same for those).
  # 
  # @param include_super  (see NRSER.method_objects_for)
  # @param sort:          (see NRSER.method_objects_for)
  # 
  # @return [Array<Method>]
  #   List of method objects (all bound to `self`).
  # 
  def class_method_objects include_super = true, sort: true
    NRSER.method_objects_for  self,
                              include_super,
                              type: :class,
                              sort: sort
  end
  
  alias_method :class_Methods, :class_method_objects
  
  
  # Just get the class methods defined in this module (or class) itself,
  # omitting inherited ones.
  # 
  # Equivalent to
  # 
  #     #class_method_objects false
  # 
  # @param sort:  (see .class_method_objects)
  # @return       (see .class_method_objects)
  # 
  def own_class_method_objects sort: true
    class_method_objects false, sort: sort
  end
  
  alias_method :own_class_Methods, :own_class_method_objects
  
  
  # Get instance methods for this {Module} (or {Class}).
  # 
  # @param include_super  (see NRSER.method_objects_for)
  # @param sort:          (see NRSER.method_objects_for)
  # 
  # @param [Boolean] include_initialize
  #   When `true`, include `#initialize` method if it's defined, which is
  #   normally excluded from {Module#instance_methods}.
  #   
  #   Respects  `include_super` - won't include it if we are only looking for
  #   own instance methods and it's inherited.
  # 
  # @return [Array<UnboundMethod>]
  #   List of method objects (all unbound).
  # 
  def instance_method_objects include_super = true,
                              sort: true,
                              include_initialize: false
    NRSER.method_objects_for \
      self,
      include_super,
      type: :instance,
      sort: sort,
      include_initialize: include_initialize
  end # #instance_method_objects
  
  alias_method :instance_Methods, :instance_method_objects
  
  
  # Just get the instance methods defined in this {Module} (or {Class}) itself,
  # omitting inherited ones.
  # 
  # Equivalent to
  # 
  #     #instance_method_objects false
  # 
  # @param sort:                (see #instance_method_objects)
  # @param include_initialize:  (see #instance_method_objects)
  # 
  # @return                     (see #instance_method_objects)
  # 
  def own_instance_method_objects sort: true,
                                  include_initialize: false
    instance_method_objects false,
                            sort: sort,
                            include_initialize: include_initialize
  end
  
  alias_method :own_instance_Methods, :own_instance_method_objects
  
  # @!endgroup {Method} Object Readers
  
end # class Module
