# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './props/class_methods'
require_relative './props/instance_methods'


# Refinements
# ========================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

# @todo
#   This really needs a write-up... but it's not a very simple thing.
# 
module Props
  DEFAULT_CLASS_KEY = '__class__';
  
  def self.included base
    base.include  NRSER::Props::InstanceMethods
    base.extend   NRSER::Props::ClassMethods
  end
  
  # Instantiate a class from a data hash. The hash must contain the
  # `__class__` key and the target class must be loaded already.
  # 
  # **WARNING**
  # 
  # I'm sure this is all-sorts of unsafe. Please don't ever think this is
  # reasonable to use on untrusted data.
  # 
  # @param [Hash<String, Object>] data
  #   Data hash to load from.
  # 
  # @param
  # 
  # @return [NRSER::Props::Props]
  #   Instance of a propertied class.
  # 
  def self.UNSAFE_load_instance_from_data data, class_key: DEFAULT_CLASS_KEY
    t.hash_.check data
    
    unless data.key?( class_key )
      raise ArgumentError.new binding.erb <<-ERB
        Data is missing <%= class_key %> key - no idea what class to
        instantiate.
        
        Data:
        
            <%= data.pretty_inspect %>
        
      ERB
    end
    
    # Get the class name from the data hash using the key, checking that it's
    # a non-empty string.
    class_name = t.non_empty_str.check! data[class_key]
    
    # Resolve the constant at that name.
    klass = class_name.to_const!
    
    # Make sure it's one of ours
    unless klass.included_modules.include?( NRSER::Props )
      raise ArgumentError.new binding.erb <<-ERB
        Can not load instance from data - bad class name.
        
        Extracted class name
        
            <%= class_name.inspect %>
        
        from class key
        
            <%= class_key.inspect %>
        
        which resolved to constant
        
            <%= klass.inspect %>
        
        but that class does not include the NRSER::Props::Props mixin, which we
        check for to help protect against executing an unrelated `.from_data`
        class method when attempting to load.
        
        Data:
        
            <%= data.pretty_inspect %>
        
      ERB
    end
    
    # Kick off the restore and return the result
    klass.from_data data
    
  end # .UNSAFE_load_instance_from_data
end # module Props


# /Namespace
# ========================================================================

end # module NRSER
