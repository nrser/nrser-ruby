# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

# Need {Module#anonymous?}
require 'active_support/core_ext/module/anonymous'

# Project / Package
# -----------------------------------------------------------------------

# Need {String#underscore}, etc.
require 'nrser/core_ext/string'

# Need {NRSER::Meta::Source::Location.for_methods}
require 'nrser/meta/source/location'

# Need {Module.class_method_objects}, etc.
require_relative './method_objects'


# Definitions
# =======================================================================

# Extension methods for {Module}
# 
class Module
  
  # @!group Source Location Readers
  # ==========================================================================
  
  # Map class method names to the their source locations.
  # 
  # @see NRSER::Meta::Source::Location.for_methods
  # 
  # @param include_super  (see Module#class_method_objects)
  # @param sort:          (see Module#class_method_objects)
  # @param only_valid:    (see NRSER::Meta::Source::Location.for_methods)
  # 
  # @return (see NRSER::Meta::Source::Location.for_methods)
  # 
  def class_method_locations  include_super = true,
                              sort: true,
                              only_valid: false
    NRSER::Meta::Source::Location.for_methods \
      class_method_objects( include_super, sort: sort ),
      only_valid: only_valid
  end
  
  
  # Just calls {#class_method_locations} with `include_super = false`.
  # 
  # @param sort:        (see #class_method_locations)
  # @param only_valid:  (see #class_method_locations)
  # 
  # @return             (see #class_method_locations)
  # 
  def own_class_method_locations  sort: true,
                                  only_valid: false
    class_method_locations false, sort: sort, only_valid: only_valid
  end
  
  
  # Map instance method names to the their source locations.
  # 
  # @see NRSER::Meta::Source::Location.for_methods
  # 
  # @param include_super        (see Module#instance_method_objects)
  # @param sort:                (see Module#instance_method_objects)
  # @param include_initialize:  (see Module#instance_method_objects)
  # @param only_valid:          (see NRSER::Meta::Source::Location.for_methods)
  # 
  # @return (see NRSER::Meta::Source::Location.for_methods)
  # 
  def instance_method_locations   include_super = true,
                                  sort: true,
                                  include_initialize: false,
                                  only_valid: false
    NRSER::Meta::Source::Location.for_methods \
      instance_method_objects(
        include_super,
        sort: sort,
        include_initialize: include_initialize,
      ),
      only_valid: only_valid
  end
  
  
  # Just calls {#instance_method_locations} with `include_super = false`.
  # 
  # @param sort:                (see #instance_method_locations)
  # @param include_initialize:  (see #instance_method_locations)
  # @param only_valid:          (see NRSER::Meta::Source::Location.for_methods)
  # 
  # @return (see #instance_method_locations)
  # 
  def own_instance_method_locations sort: true,
                                    include_initialize: false,
                                    only_valid: false
    instance_method_locations false,
                              sort: sort,
                              include_initialize: include_initialize,
                              only_valid: only_valid
  end
  
  
  # Get *all* source locations for that module (or class) methods.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [Hash<Method, Array<String, Fixnum>>]
  #   @todo Document return value.
  # 
  def method_locations only_valid: false
    # Get all the src locs for own methods
    own_class_method_locations( only_valid: only_valid ).
      map { |name, location|
        [".#{ name }", location]
      }.
      to_h.
      merge! \
        own_instance_method_locations(  only_valid: only_valid,
                                        include_initialize: true ).
          map { |name, location|
            ["##{ name }", location]
          }.to_h
  end # .module_source_locations
  
  
  # Get the "canonical" lib-relative path for this module based off it's
  # {#name} (via {String#underscore}, with `'.rb'` suffixed).
  # 
  # @todo
  #   I bet ActiveSupport has some method for this re auto-loading.
  # 
  # @return [nil]
  #   If this module is {#anonymous?}.
  # 
  # @return [Pathname]
  #   If this module is not {#anonymous?}.
  # 
  def canonical_rel_path
    if anonymous?
      nil
    else
      Pathname.new( name.underscore + '.rb' )
    end
  end # #canocical_rel_path
  
  
  # Try to find a reasonable file and line for the module (or class) by
  # looking at the locations of it's methods.
  # 
  # @return [NRSER::Meta::Source::Location]
  #   Two entry array; first entry is the string file path, second is the
  #   line number.
  #   
  #   Note that both will be `nil` if we can't find a source location
  #   (the location will not be {NRSER::Meta::Source::Location#valid?}).
  # 
  def source_location
    # Get all the src locs for all methods
    locations = method_locations only_valid: true
    
    # Short circuit if we don't have shit to work with...
    return NRSER::Meta::Source::Location.new if locations.empty?
    
    # If any files end with the "canonical path" then use that. It's a path
    # suffix
    # 
    #     "my_mod/sub_mod/some_class.rb"
    # 
    # the for a class
    # 
    #     MyMod::SubMod::SomeClass
    # 
    canonical_rel_path = self.canonical_rel_path
    
    unless canonical_rel_path.nil?
      
      # Find first line in canonical path (if any)
      canonical_path_location = locations.
        values.
        find_all { |(path, line)| path.end_with? canonical_rel_path.to_s }.
        min_by { |(path, line)| line }
      
      # If we found one, we're done!
      return canonical_path_location if canonical_path_location
      
    end
    
    # OK, that didn't work, so...
    
    # If it's a {Class} and it has an `#initialize` method, point there.
    # 
    if is_a?( Class ) && locations['#initialize']
      return locations['#initialize']
    end
    
    # No dice. Moving on...
    
    # Get the first line on the shortest path
    locations.values.min_by { |(path, line)|
      [path.length, line]
    }
  end # .module_source_location
  
  # @!endgroup Source Location Readers
  
end # class Module
