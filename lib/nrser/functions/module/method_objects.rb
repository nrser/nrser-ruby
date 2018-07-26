# encoding: UTF-8
# frozen_string_literal: true

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
  
  # @!endgroup Module Functions
  
end # module NRSER
