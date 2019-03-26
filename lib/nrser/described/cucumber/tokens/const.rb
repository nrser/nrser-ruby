# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

# {Name} subclasses wrap name patterned classes
require 'nrser/meta/names'

# {Const} extends {Name}
require_relative './name'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Tokens


# Definitions
# =======================================================================

# Token that matches constant names by extending {Name} and referencing
# {NRSER::Meta::Names::Const}.
# 
class Const < Name
  
  # Config
  # ==========================================================================
  
  # Constant names are `{...}` quoted.
  quote :curly
  
  # Name used to match inside the quotes.
  name_class    NRSER::Meta::Names::Const
  
  # Resolved values can be anything
  to_value_type   ::Object
  
  
  # Singleton Methods
  # ========================================================================
  
  # @!group Transformation Conversion Singleton Methods
  # --------------------------------------------------------------------------
  
  def self.to_class_type
    ::Class
  end
  
  def self.to_module_type
    ::Module
  end
  
  # @!endgroup Additional Transformation Singleton Methods # *****************
  
  
  # Instance Methods
  # ========================================================================
  
  # @!group {Token} API Instance Methods
  # --------------------------------------------------------------------------
  
  # Support for standard value resolution. Calls
  # {World::Scope#resolve_const} on the scenario instance (`self_obj`).
  # 
  # @param [::Object] self_obj
  #   The scenario instance (that all steps are evaluated in). Actually *is*
  #   a direct instance of {::Object} with a ton of singleton class extensions.
  # 
  # @return [::Object]
  #   
  def to_value self_obj
    self_obj.resolve_const unquote
  end
  
  # @!endgroup {Token} API Instance Methods # ********************************
  
  
  # @!group Additional Transformation Instance Methods
  # --------------------------------------------------------------------------
  # 
  # Supporting additional transformations resolving {::Class} and {::Module}
  # constants specifically.
  # 
  # Along with corresponding singleton methods providing the "types" (Cucumber 
  # parameter type lingo: the {::Class} that all return values are instances of,
  # not an {NRSER::Types::Type}) these allow providing
  # 
  #     transformer: :to_class
  # 
  # or
  # 
  #     transformer: :to_module
  # 
  # at {ParameterTypes::ParameterType} construction, and our parameter type
  # class will do the right thing using the same mechanics that handle 
  # `:unquote` and `:to_value`.
  # 
  # Pretty spiffy, huh?
  # 
  
  def to_class self_obj
    self_obj.resolve_class unquote
  end
  
  
  def to_module self_obj
    self_obj.resolve_module unquote
  end
  
  # @!endgroup Additional Transformation Instance Methods # ******************
  
end # class Const


# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
