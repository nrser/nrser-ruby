# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/errors/argument_error'

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
  # @param [String] class_key
  #   The key name to look for the class name in.
  # 
  # @return [NRSER::Props::Props]
  #   Instance of a propertied class.
  # 
  def self.UNSAFE_load_instance_from_data data, class_key: DEFAULT_CLASS_KEY
    t.hash_.check data
    
    unless data.key?( class_key )
      raise NRSER::ArgumentError.new \
        "Data is missing", class_key,
        "key - no idea what class to instantiate.",
        class_key: class_key,
        data: data
    end
    
    # Get the class name from the data hash using the key, checking that it's
    # a non-empty string.
    class_name = t.non_empty_str.check! data[class_key]
    
    # Resolve the constant at that name.
    klass = class_name.to_const!
    
    # Make sure it's one of ours
    unless klass.included_modules.include?( NRSER::Props )
      raise NRSER::ArgumentError.new \
        "Can not load instance from data - bad class name.",
        class_name: class_name,
        class_key: class_key,
        resolved_constant: klass,
        data: data,
        details: <<~END
          `resolved_constant` does not include the {NRSER::Props} mixin, which
          we check for to help protect against executing an unrelated 
          `.from_data` class method when attempting to load.
        END
    end
    
    # Kick off the restore and return the result
    klass.from_data data
    
  end # .UNSAFE_load_instance_from_data
end # module Props


# /Namespace
# ========================================================================

end # module NRSER
