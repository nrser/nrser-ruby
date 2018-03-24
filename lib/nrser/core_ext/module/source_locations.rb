
# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# We want {String#underscore}, etc.
require 'active_support/core_ext/module/anonymous'

# Project / Package
# -----------------------------------------------------------------------

# Want {Enumerable#assoc_to}
require 'nrser/core_ext/enumerable'

# Want {String#underscore}, etc.
require 'nrser/core_ext/string'

require_relative './method_objects'

# Extension methods for {Module}
# 
class Module
  
  # @!group Source Location Readers
  # ==========================================================================
  
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
  
  
  # Get *all* source locations for that module (or class) methods.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [Hash<Method, Array<String, Fixnum>>]
  #   @todo Document return value.
  # 
  def method_source_locations
    # Get all the src locs for own methods
    [
      own_class_method_objects,
      own_instance_method_objects( include_initialize: true ),
    ].
      # Associate {Method} instances with their source location and merge
      # them all together into `Hash<Method, Array<String?, Fixnum?>>`
      reduce( {} ) { |methods, results|
        results.merge methods.assoc_to( &:source_location )
      }.
      # Filter out any that don't have full src loc info
      reject { |method, src_loc| src_loc.nil? || src_loc.any?( &:nil? ) }
  end # .module_source_locations
  
  
  # @todo Document canocical_rel_path method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def canonical_rel_path
    if anonymous?
      nil
    else
      Pathname.new( name.underscore + '.rb' )
    end
  end # #canocical_rel_path
  
  
  # Get a reasonable file and line for the module (or class).
  # 
  # @return [Array<(String, Fixnum)>]
  #   Two entry array; first entry is the string file path, second is the
  #   line number.
  # 
  def source_location
    # If any files end with the "canonical path" then use that. It's a path
    # suffix
    # 
    #     "my_mod/sub_mod/some_class.rb"
    # 
    # the for a class
    # 
    #     MyMod::SubMod::SomeClass
    # 
    canonical_path_end = self.name
      ActiveSupport::Inflector.underscore( mod.name ) + '.rb'
    
    # Get all the src locs for `mod`'s methods
    # src_locs = method_source_locations( only:  )
    
    # Find first line in canonical path (if any)
    canonical_path_src_loc = source_locations.
      select( &:valid? ).
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
  
  # @!endgroup Source Location Readers
  
end # class Module
