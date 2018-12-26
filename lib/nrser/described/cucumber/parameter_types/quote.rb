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


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# =======================================================================

# Mixin that provides methods for quoting and unquoting.
# 
module Quote
  
  def curly_quote *patterns
    re.join re.esc( '{' ), *patterns, re.esc( '}' )
  end


  def curly_quoted? string
    string[ 0 ] == '{' && string[ -1 ] == '}'
  end


  def curly_unquote string
    if curly_quoted? string
      string[ 1..-2 ]
    else
      string
    end
  end


  def backtick_quote *patterns
    re.join re.esc( '`' ), *patterns, re.esc( '`' )
  end


  def backtick_quoted? string
    # !string.is_a?( SourceString ) &&
    ( string[ 0 ] == '`' && string[ -1 ] == '`' )
  end


  def backtick_unquote string
    # return string if string.is_a?( SourceString )
    
    if backtick_quoted? string
      # SourceString.new string[ 1..-2 ]
      string[ 1..-2 ]
    else
      string
    end
  end
  
  
  def unquote string
    if backtick_quoted? string
      backtick_unquote string
    elsif curly_quoted? string
      curly_unquote string
    else
      string
    end
  end
  
      
end # module Quote  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
