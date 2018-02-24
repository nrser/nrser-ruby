# encoding: UTF-8
# frozen_string_literal: true

using NRSER

# Definitions
# =======================================================================

module NRSER
  
  # @!group Module Functions
  # ==========================================================================
  
  
  # @todo Document map_to_source_locations method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [Hash<#source_location, Array<(String?, Fixnum?)>?>]
  #   Map of objects
  # 
  def self.map_to_source_locations methods
    methods.assoc_to &:source_location
  end # .map_to_source_locations
  
  
  # Map class method {Methods} objects to the `#source_location` for `mod`
  # class methods.
  # 
  # @see https://ruby-doc.org/core/Method.html#method-i-source_location
  # 
  # @param (see NRSER.class_method_objects_for)
  # 
  # @return [Hash<Symbol, Array<(String?, Fixnum?)>?>]
  #   Hash mapping method name {Symbol}s to results of calling their
  #   {Method#source_location}, which seems to be able to be:
  #   
  #   1.  `Array<(String, Fixnum)>` - two-entry array of file path,
  #       line number.
  #   
  #   2.  `nil` - if this method was not defined in Ruby (C extension, etc.)
  #       
  #   3.  `Array<(nil, nil)>` - Not listed as a possibility in the docs, but
  #       I swear I've seen it, so watch out.
  # 
  def self.class_method_source_locations_for *args
    map_to_source_locations class_method_objects_for( *args )
  end # .class_method_source_locations
  
  
  # Map *own* (not inherited) class method {Methods} objects to the
  # `#source_location` for `mod` class methods.
  # 
  # @see https://ruby-doc.org/core/Method.html#method-i-source_location
  # 
  # @param  (see .own_class_method_objects_for)
  # @return (see .class_method_objects_for)
  # 
  def self.own_class_method_source_locations_for *args
    map_to_source_locations own_class_method_objects_for( *args )
  end # .own_class_method_source_locations_for
  
  
  # Map instance method {Methods} objects to the `#source_location` for `mod`
  # class methods.
  # 
  # @see https://ruby-doc.org/core/Method.html#method-i-source_location
  # 
  # @param (see .instance_method_objects_for)
  # @return (see .class_method_source_locations_for)
  # 
  def self.instance_method_source_locations_for *args
    map_to_source_locations instance_method_objects_for( *args )
  end # .class_method_source_locations


  # Map *own* (not inherited) class method {Methods} objects to the
  # `#source_location` for `mod` class methods.
  # 
  # @see https://ruby-doc.org/core/Method.html#method-i-source_location
  # 
  # @param  (see NRSER.own_class_method_objects_for)
  # @return (see NRSER.class_method_objects_for)
  # 
  def self.own_instance_method_source_locations_for *args
    map_to_source_locations own_instance_methods_objects_for( *args )
  end # .own_class_method_source_locations_for
  
  
  # @todo Document method_source_locations_for method.
  # 
  # @param [type] mod
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.method_source_locations_for  mod,
                                        include_super = false,
                                        sort: true
    class_method_source_locations_for(
      mod,
      include_super,
      sort: sort,
    ).
      # map_keys { |name| ".#{ name }" }.
      merge instance_method_source_locations_for(
        mod,
        include_super,
        sort: sort,
        # Think it makes sense to *always* include `#initialize` since at this
        # point we're interested in where *all* the methods are, and that
        # should def be included.
        include_initialize: true,
      ) # .map_keys { |name| "##{ name }" }
  end # .method_source_locations_for
  
  
  def self.own_method_source_locations_for  mod,
                                            sort: true
    method_source_locations_for \
      mod,
      false,
      sort: sort
  end # .method_source_locations_for
  
  
  
  # @todo Document module_source_locations method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.module_source_locations mod
    # Get all the src locs for `mod`'s methods
    own_method_source_locations_for( mod ).values.
      # Filter out any that don't have full src loc info
      reject { |src_loc| src_loc.nil? || src_loc.any?( &:nil? ) }
  end # .module_source_locations
  

  
  # Get a reasonable file and line for the class.
  # 
  # @param [Class] cls
  #   Class to try and locate.
  # 
  # @return [Array<(String, Fixnum)>]
  #   Two entry array; first entry is the string file path, second is the
  #   line number.
  # 
  def self.module_source_location mod
    # If any files end with the "canonical path" then use that. It's a path
    # suffix
    # 
    #     "my_mod/sub_mod/some_class.rb"
    # 
    # the for a class
    # 
    #     MyMod::SubMod::SomeClass
    # 
    canonical_path_end = \
      ActiveSupport::Inflector.underscore( mod.name ) + '.rb'
    
    # Get all the src locs for `mod`'s methods
    src_locs = module_source_locations mod
    
    # Find first line in canonical path (if any)
    canonical_path_src_loc = src_locs.
      find_all { |(path, line)| path.end_with? canonical_path_end }.
      min_by { |(path, line)| line }
    
    # If we found one, we're done!
    return canonical_path_src_loc if canonical_path_src_loc
    
    raise "HERE"
    
    klass.
      # Get an array of all instance methods, excluding inherited ones
      # (the `false` arg)
      instance_methods( false ).
      # Add `#initialize` since it isn't in `#instance_methods` for some
      # reason
      <<( :initialize ).
      # Map those to their {UnboundMethod} objects
      map { |sym| klass.instance_method sym }.
      # Toss any `nil` values (TODO how/why?)
      compact.
      # Get the source locations
      map( &:source_location ).
      # Get rid of `[nil, nil]` results, which seems to come from C exts?
      reject { |(path, line)| path.nil? || line.nil? }.
      # Get the first line in the shortest path
      min_by { |(path, line)| [path.length, line] }
      
      # Another approach I thought of... (untested)
      # 
      # Get the path
      # # Get frequency of the paths
      # count_by { |(path, line)| path }.
      # # Get the one with the most occurrences
      # max_by { |path, count| count }.
      # # Get just the path (not the count)
      # first
  end # .module_source_location
  
  # @!endgroup Module Functions
  
end # module NRSER
