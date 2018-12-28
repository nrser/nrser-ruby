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

# {Name} extends {Token}
require_relative './token'


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

  
class Name < Token

  def self.name_class name_class = nil
    unless name_class.nil?
      unquote_type name_class
      pattern send( "#{ quote }_quote", name_class )
    end
    
    unquote_type
  end
  
  def unquote
    self.class.unquote_type.new super()
  end
  
end # class Name

  
class Const < Name
  
  quote :curly
  name_class    NRSER::Meta::Names::Const
  to_value_type   ::Object
  
  def self.to_class_type
    ::Class
  end
  
  def self.to_module_type
    ::Module
  end
  
  def to_value self_obj
    self_obj.resolve_const unquote
  end
  
  def to_class self_obj
    self_obj.resolve_class unquote
  end
  
  
  def to_module self_obj
    self_obj.resolve_module upquote
  end
end # class Const


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


class Var < Name
  
  quote :backtick
  
  class Local < Var
    name_class NRSER::Meta::Names::Var::Local
  end
  
  class Instance < Var
    name_class NRSER::Meta::Names::Var::Instance
  end
  
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
