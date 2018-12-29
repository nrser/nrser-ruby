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

# Tokens that match variables names by extending {Name} and referencing
# {NRSER::Meta::Names::Var} subclasses.
# 
class Var < Name
  
  # Config
  # ==========================================================================
  
  # All variable tokens are backtick (`) quoted.
  quote :backtick
  
  
  # Subclasses
  # ==========================================================================
  
  # {Var} token matching local variable names via
  # {NRSER::Meta::Names::Var::Local}.
  # 
  class Local < Var
    name_class NRSER::Meta::Names::Var::Local
  end
  
  
  # {Var} token matching instance variable names via
  # {NRSER::Meta::Names::Var::Instance}.
  # 
  class Instance < Var
    name_class NRSER::Meta::Names::Var::Instance
  end
  
  
  # {Var} token matching global variable names (really, anything starting with
  # `$`) via {NRSER::Meta::Names::Var::Global}.
  # 
  class Global < Var
    name_class NRSER::Meta::Names::Var::Global
  end
  
end # class Var


# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
