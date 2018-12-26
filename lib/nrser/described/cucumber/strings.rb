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


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Various subclasses of {NRSER::Strings::Patterned} used to recognize and
# process classes of string input from Cucumber feature files.
# 
module Strings
  class Base < NRSER::Strings::Patterned; end
  
  # Ruby source code ready to be evaluated.
  class Code < Base
    pattern '.*'
  end
  
  
  # A string that is quoted in backticks (`).
  # 
  # It is *not* {Code}, because it needs to have the backticks stripped first,
  # and possibly be transformed if it's using our funky unary ampersand feature
  # to denote it's a block parameter value.
  # 
  class BacktickQuotedCode < Base
    pattern backtick_quote_re( '[^\`]*' )
    
    transformer do |string|
      string[ 1..-2 ]
    end
  end
  
  
  # Regular expressions are copied from
  # {::Cucumber::CucumberExpressions::ParameterTypeRegistry} (MIT license).
  # 
  module Literal
    class Base < NRSER::Described::Cucumber::Strings::Base
    end
    
    class String < Base
      pattern /"([^"\\]*(\\.[^"\\]*)*)"|'([^'\\]*(\\.[^'\\]*)*)'/
      
      transformer do |string|
        string.gsub(/\\"/, '"').gsub(/\\'/, "'")
      end
    end
    
    class Integer < Base
      pattern re.or( /-?\d+/, /\d+/ )
      
      transformer do |string|
        string.to_i
      end
    end
    
    class Float < Base
      pattern /-?\d*\.\d+/
      
      transformer do |string|
        string.gsub(/\\"/, '"').gsub(/\\'/, "'")
      end
    end
    
  end # module Literal
  
  
  class Expression < Base
    pattern re.or( BacktickQuotedCode, StringLiteral, full: true )
  end
  
  
  module Link
    class Base < NRSER::Described::Cucumber::Strings::Base
    end
    
    class Constant < Base
      pattern curly_quote_re( NRSER::Meta::Names::Constant )
    end
    
    class QualifiedSingletonMethod < Base
      pattern curly_quote_re( NRSER::Meta::Names::QualifiedSingletonMethod )
    end
    
    class QualifiedInstanceMethod < Base
      pattern curly_quote_re( NRSER::Meta::Names::QualifiedInstanceMethod )
    end
    
    # A link that can be resolved to a value all by itself, without needing
    # a implicit context
    class Explicit
      pattern \
        re.or( Constant, QualifiedSingletonMethod, QualifiedInstanceMethod )
    end
    
  end
  
  
  class Value < Base
    pattern re.or( Expression, Link::Explicit )
  end
  
  
  # A YARD-style, curly-bracket-quoted string 
  # 
  # @example *Absolute* link to a constant
  #   # {::Module}, in this case
  #   Link.new "{::NRSER::Described::Cucumber}"
  #   
  #   # Though a {::Class} or other constant would work fine as well
  #   Link.new "{::NRSER::VERSION}"
  # 
  # @example *Relative* link to a constant
  #   # {::Class}, in this case, though {::Module} or other constant would work
  #   # fine as well. What's important is that this one will first resolve from
  #   # the scenario scope before globally.
  #   Link.new "{Base}"
  # 
  # @example *Unqualified* link to a singleton method
  #   Link.new "{.some_singleton_method}""
  # 
  # @example *Unqualified* link to a instance method
  #   Link.new "{#some_instance_method}"
  # 
  # @example *Qualified* *absolute* link to a singleton method
  #   Link.new "{::NRSER::Strings::Patterned.pattern}"
  # 
  # @example *Qualified* *relative* link to an instance method
  #   Link.new "{A::B#f}"
  # 
  class ConstLink
    pattern re.or(
      
    )
  end
  

  
  
  
  
  
end # module ParameterTypes

# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
