# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Module

  # Class Methods
  # ========================================================================

  # Core class method that supports all the other "method getters".
  # 
  # Implemented as a class method 'cause it used to be part of
  # `//lib/nrser/functions`.
  # 
  # @param [Module] mod
  #   Module in question.
  # 
  # @param [Boolean] include_super
  #   When `true`, includes inherited class methods.
  # 
  # @param [:class | :instance] type
  #   Get class or instance methods.
  # 
  # @param [Boolean] sort
  #   If `true`, will sort the methods by name, which is usually
  #   the useful way to look at and use them.
  # 
  # @return [Array<(Method | UnboundMethod)>]
  #   List of method objects (all bound to `mod`).
  # 
  def self.method_objects_for mod,
                              include_super,
                              type:,
                              sort:,
                              include_initialize: false
    initialize_method = nil
    
    get_names, get_method = case type
    when :class
      [:methods, :method]
      
    when :instance
      if include_initialize
        # Only way I can figure out to find out if it is defined it to try
        # to get the object and handle the error
        begin
          initialize_method = mod.instance_method :initialize
        rescue NameError => error
        else
          # Don't want to include it if we're not `include_super` and it's
          # inherited from a different module
          unless include_super || initialize_method.owner == mod
            initialize_method = nil
          end
        end
      end
      
      [:instance_methods, :instance_method]
      
    else
      raise ArgumentError,
        "`type:` must be `:class` or `:instance`, found #{ type.inspect }"
      
    end # case type
    
    methods = mod.send( get_names, include_super ).map { |name|
      mod.send get_method, name
    }
    
    methods << initialize_method unless initialize_method.nil?
    
    methods.sort! { |a, b| a.name <=> b.name } if sort
    
    methods
  end # .method_objects_for


  # Instance Methods
  # ========================================================================

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
    MethodObjects.method_objects_for \
      self,
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
    MethodObjects.method_objects_for \
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
  
end # module Module


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
