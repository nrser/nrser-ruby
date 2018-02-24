# encoding: UTF-8
# frozen_string_literal: true
##
# Functions to get {Method} and {UnboundMethod} instances for class and
# instance methods (respectively) of a {Module}.
# 
# @note
#   Methods added to {NRSER::Ext::Module} can't be named the same as they will
#   be in the extension due to shadowing.
# 
## 


# Definitions
# =======================================================================

module NRSER
  
  # @!group Module Functions
  # ==========================================================================
  
  # Core private method that supports all the other "method getters".
  # 
  # @private
  # 
  # @param [Module] mod
  #   Module in question.
  # 
  # @param [Boolean] include_super
  #   When `true`, includes inherited class methods.
  # 
  # @param [:class | :instance] type:
  #   Get class or instance methods.
  # 
  # @param [Boolean] sort:
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
  
  private_class_method :method_objects_for
  
  
  # Get class methods for a {Module} ({Class} are also {Module}, so works
  # same for those).
  # 
  # @param mod            (see .method_objects_for)
  # @param include_super  (see .method_objects_for)
  # @param sort:          (see .method_objects_for)
  # 
  # @return [Array<Method>]
  #   List of method objects (all bound to `mod`).
  # 
  def self.class_method_objects_for mod, include_super = true, sort: true
    method_objects_for mod, include_super, type: :class, sort: sort
  end # .class_method_objects_for
  
  # Much shorter name
  # 
  # @todo Not sure if I like this...
  # 
  singleton_class.send  :alias_method,
                        :class_Methods_for, :class_method_objects_for
  
  
  # Just get the class methods defined in `mod` itself, omitting inherited
  # ones.
  # 
  # Equivalent to
  # 
  #     NRSER.class_method_objects_for false
  # 
  # @param mod    (see .class_method_objects_for)
  # @param sort:  (see .class_method_objects_for)
  # @return       (see .class_method_objects_for)
  # 
  def self.own_class_method_objects_for mod, sort: true
    class_method_objects_for mod, false, sort: sort
  end # .own_class_method_objects_for
  
  # Much shorter name
  # 
  # @todo Not sure if I like this...
  # 
  singleton_class.send  :alias_method,
                        :own_class_Methods_for,
                        :own_class_method_objects_for
  
  
  # Get instance methods for a {Module} ({Class} are also {Module}, so works
  # same for those).
  # 
  # @param mod            (see .method_objects_for)
  # @param include_super  (see .method_objects_for)
  # @param sort:          (see .method_objects_for)
  # 
  # @param [Boolean] include_initialize:
  #   When `true`, include `#initialize` method if it's defined, which is
  #   normally excluded from {Module#instance_methods}.
  #   
  #   Respects  `include_super` - won't include it if we are only looking for
  #   own instance methods and it's inherited.
  # 
  # @return [Array<UnboundMethod>]
  #   List of method objects (all unbound).
  # 
  def self.instance_method_objects_for  mod,
                                        include_super = true,
                                        sort: true,
                                        include_initialize: false
    method_objects_for \
      mod,
      include_super,
      type: :instance,
      sort: sort,
      include_initialize: include_initialize
  end # .instance_method_objects_for
  
  # Much shorter name
  # 
  # @todo Not sure if I like this...
  # 
  singleton_class.send  :alias_method,
                        :instance_Methods_for, :instance_method_objects_for
  
  
  # Just get the instance methods defined in `mod` itself, omitting inherited
  # ones.
  # 
  # Equivalent to
  # 
  #     NRSER.instance_method_objects_for false
  # 
  # @param mod    (see .instance_method_objects_for)
  # @param sort:  (see .instance_method_objects_for)
  # @return       (see .instance_method_objects_for)
  # 
  def self.own_instance_method_objects_for  mod,
                                            sort: true,
                                            include_initialize: false
    instance_method_objects_for \
      mod,
      false,
      sort: sort,
      include_initialize: include_initialize
  end # .own_instance_method_objects_for
  
  # Much shorter name
  # 
  # @todo Not sure if I like this...
  # 
  singleton_class.send  :alias_method,
                        :own_instance_Methods_for,
                        :own_instance_method_objects_for
  
  
  # @!endgroup Module Functions
  
end # module NRSER
