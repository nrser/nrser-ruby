# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::String#camelize}
require 'active_support/core_ext/string/inflections'

# Using {::Class#descendants}
require 'active_support/core_ext/class/subclasses'

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Regexps::Composed.or}
require 'nrser/regexps/composed'

require_relative './described/attribute'
require_relative './described/base'
require_relative './described/class'
require_relative './described/error'
require_relative './described/hierarchy'
require_relative './described/instance_method'
require_relative './described/method'
require_relative './described/module'
require_relative './described/object'
require_relative './described/response'


require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# ========================================================================

module  NRSER


# Definitions
# =======================================================================

module Described
  def self.human_name_pattern full: false, options: nil
    NRSER::Regexps::Composed.or \
      *Base.descendants.flat_map { |cls|
        cls.human_names.map { |human_name| ::Regexp.escape human_name }
      },
      full: full,
      options: options
  end
  
  
  def self.class_name_for name_ish
    camelized = name_ish.to_s.camelize
    
    prefix = "#{ self.name }::"
    
    unless camelized.start_with? prefix
      camelized = prefix + camelized
    end
    
    camelized
  end
  
  
  def self.class_for_name! class_name
    t.SubclassOf( Base ).check! const_get( class_name_for class_name )
  end
  
  
  def self.class_for_name class_name
    class_for_name! class_name
  rescue Types::CheckError => error
    nil
  end
  
end # module Described


# /Namespace
# ========================================================================

end # module NRSER
