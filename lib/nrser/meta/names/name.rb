# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::Class#descendants}
require 'active_support/core_ext/class/subclasses'

# Project / Package
# -----------------------------------------------------------------------

# {Name}s extend {NRSER::Strings::Patterned}
require 'nrser/strings/patterned'


# Namespace
# =======================================================================

module  NRSER
module  Meta
module Names


# Definitions
# =======================================================================

# Abstract base class for Ruby constant and method name strings.
# 
# @abstract
# 
class Name < NRSER::Strings::Patterned
  
  # Singleton Methods
  # ========================================================================
  
  # Old method before {NRSER::Ext::Class#subclass?} existed, just proxies
  # to {.subclass?}.
  # 
  def self.name_subclass? object
    subclass? object
  end
  
  
  # def self.from string
  #   string = string.to_s unless string.is_a?( ::String )
    
  #   [ Positional,
  #     Keyword,
  #     Block,
  #     Rest,
  #     KeyRest,
  #   ].each do |concrete_class|
  #     return concrete_class.new( string ) if concrete_class.pattern =~ string
  #   end
    
  #   raise NRSER::ArgumentError.new \
  #     "Unable to create concrete", self, "subclass instance from",
  #     string.inspect
  # end
  
  
end # class Name


# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
