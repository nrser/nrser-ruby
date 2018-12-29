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

class Param < Name
  quote :backtick

  class Positional < Param
    name_class NRSER::Meta::Names::Param::Positional
  end
  
  class Keyword < Param
    name_class NRSER::Meta::Names::Param::Keyword
  end
  
  class Block < Param
    name_class NRSER::Meta::Names::Param::Block
  end
  
  class Rest < Param
    name_class NRSER::Meta::Names::Param::Rest
  end
  
  class KeyRest < Param
    name_class NRSER::Meta::Names::Param::KeyRest
  end
  
end # class Param


# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
