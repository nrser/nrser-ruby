# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './name'
require_relative './var'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Meta
module  Names


# Definitions
# =======================================================================

# Abstract base class for parameter names, defining the interface.
# 
# @abstract
# 
class Param < Name
  
  # The part of the parameter name that is used as the variable name (which
  # may be the whole thing, as in {PositionalParam}).
  # 
  # @return [Variable]
  #     
  attr_reader :var_name
  
  
  def var_sym
    var_name.to_sym
  end
  
  
  def block?
    is_a? Block
  end


  class Positional < Param
    pattern Var::Local
    
    def initialize string
      @var_name = Var::Local.new string
      super( string )
    end
  end


  class Keyword < Param
    pattern Var::Local, re.esc( ':' )
    
    def initialize string
      @var_name = Var::Local.new string[ 0..-2 ]
      super( string )
    end
  end


  class Block < Param
    pattern re.esc( '&' ), Var::Local
    
    def initialize string
      @var_name = Var::Local.new string[ 1..-1 ]
      super( string )
    end
  end


  class Rest < Param
    pattern re.esc( '*' ), Var::Local
    
    def initialize string
      @var_name = Var::Local.new string[ 1..-1 ]
      super( string )
    end
  end


  class KeyRest < Param
    pattern re.esc( '**' ), Var::Local
    
    def initialize string
      @var_name = Var::Local.new string[ 2..-1 ]
      super( string )
    end
  end


end # class Param

# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
