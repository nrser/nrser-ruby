# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

# Using {::Class#descendants} in {Patterned.realizations}
require 'active_support/core_ext/class/subclasses'

### Project / Package ###

# Using {NRSER::Regexps::Composed.join} and {NRSER::Regexps::Composed.or} to
# compose {Names::Name.pattern} instances.
require 'nrser/regexps/composed'

# Using {NRSER::Ext::Class#subclass?} to safe test for subclasses
require 'nrser/ext/class/subclass'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# @todo document Strings module.
# 
module Strings
  
  def self.common_prefix *strings
    strings.flatten!
    
    raise ArgumentError.new("argument can't be empty") if strings.empty?
    
    strings.sort!
    
    index = 0
    max_index = [ strings.first.length, strings.last.length ].min
    
    while sorted.first[ index ] == sorted.last[ index ] && index < max_index
      index = index + 1
    end
    
    strings.first[ 0...index ]
  end # .common_prefix
  
end # module Strings


# /Namespace
# =======================================================================

end # module NRSER
