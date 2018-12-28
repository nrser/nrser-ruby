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

# Extends {Token}
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

# Abstract base class for literal strings, integers and floats.
# 
# @abstract
# 
class Literal < Token
  
  class String < Literal
    
    unquote_type ::String
    
    # Value for {String} literals is just them {#unquote}d.
    # 
    # @return [::String]
    # 
    def to_value
      unquote
    end
    
    # @note
    #   Regular expression and `gsub` copied from
    #   {::Cucumber::CucumberExpressions::ParameterTypeRegistry}
    #   (MIT license).
    # 
    class SingleQuoted < String
      pattern /'([^'\\]*(\\.[^'\\]*)*)'/
      
      quote :single
      
      def unquote
        [ 1.. -2 ].gsub( /\\'/, "'" )
      end
      
    end
    
    # @note
    #   Regular expression and `gsub` copied from
    #   {::Cucumber::CucumberExpressions::ParameterTypeRegistry}
    #   (MIT license).
    # 
    class DoubleQuoted < String
      pattern /"([^"\\]*(\\.[^"\\]*)*)"/
      
      quote :double
      
      def unquote
        [ 1..-2 ].gsub( /\\"/, '"' ).gsub( /\\'/, "'" )
      end
    end
    
  end # class String
  
  # @note
  #   Regular expression copied from
  #   {::Cucumber::CucumberExpressions::ParameterTypeRegistry}
  #   (MIT license).
  # 
  class Integer < Literal
    pattern re.or( /-?\d+/, /\d+/ )
    
    def to_value
      to_i
    end
  end
  
  # @note
  #   Regular expression copied from
  #   {::Cucumber::CucumberExpressions::ParameterTypeRegistry}
  #   (MIT license).
  # 
  class Float < Literal
    pattern /-?\d*\.\d+/
    
    def to_value
      to_f
    end
  end
  
end # class Literal
  

# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
