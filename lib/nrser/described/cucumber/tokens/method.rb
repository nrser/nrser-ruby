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
  
class Method < Name
  class Bare < Method
    quote :backtick   
    name_class NRSER::Meta::Names::Method::Bare
  end
  
  class Singleton < Method
    quote :curly
    name_class NRSER::Meta::Names::Method::Singleton
  end
  
  class Instance < Method
    quote :curly
    name_class NRSER::Meta::Names::Method::Instance
  end
  
  class Explicit < Method
    quote :curly
    
    class Singleton < Explicit
      name_class NRSER::Meta::Names::Method::Explicit::Singleton
    end
    
    class Instance < Explicit
      name_class NRSER::Meta::Names::Method::Explicit::Instance
    end
  end # class Explicit
end # class Method


# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
