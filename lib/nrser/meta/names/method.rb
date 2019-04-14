# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './name'
require_relative './const'

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

# Abstract base class for all method names.
# 
class Method < Name
  
  # Constants
  # ========================================================================
  
  OPERATOR_REGEXP = re.or(
    *[ %w([] []= ** ~ ~ @+ @- * / % + - >> << & ^ |),
      %w(<= < > >= <=> == === != =~ !~) ].
      flatten.
      map { |s| re.esc s },
    full: true
  )

  
  # Instance Methods
  # ========================================================================
  
  # @return [Bare]
  # 
  def bare_name
    raise ::NotImplementedError,
      "#{ self.class.name }##{ __method__ } is abstract"
  end
  
  
  def operator?
    !!( OPERATOR_REGEXP =~ bare_name )
  end
  
  
  # Subclasses
  # ==========================================================================
  
  # @todo document Bare class.
  class Bare < Method
    pattern \
      re.or( OPERATOR_REGEXP, /\A[A-Za-z_][a-zA-Z0-9_]*[\?\!]?\z/, full: true )
    
    def bare_name
      self
    end
  end # class Bare
  
  
  # Implicit Method Names
  # --------------------------------------------------------------------------
  
  # @abstract
  class Implicit < Method
    
    # Just the bare string name of the method, as you would pass to 
    # {::Object#method} or {::Module#instance_method}.
    # 
    # @return [Bare]
    #     
    attr_reader :bare_name
  
    def initialize string
      @bare_name = Bare.new string[ 1..-1 ]
      super( string )
    end
  end # class Implicit
  
  
  class Singleton < Implicit
    # resolves_to_a ::Method
    pattern       re.esc( '.' ), Bare
  end # class Singleton
  
  
  class Instance < Implicit
    # resolves_to_a ::UnboundMethod
    pattern       re.esc( '#' ), Bare
  end # class Instance
  
  
  # Explicit Method Names
  # ----------------------------------------------------------------------------
  
  # Abstract base class for method names that include an explicit receiver.
  # 
  # These names can be resolved to a method object with no further information
  # (subject to the method existing and being resolved in the correct scope).
  # 
  # Realizing classes **MUST**:
  # 
  # 1.  Override the {.separator} singleton method to return the correct string
  #     to split {Const} name and {Bare} name parts of raw strings.
  #     
  # 2.  Override {#implicit_name} to return the a name of the correct {Implicit}
  #     subclass.
  # 
  # @see Explicit::Instance
  # @see Explicit::Singleton
  # 
  class Explicit < Method
    
    # Split raw strings into their {Const} and {Bare} parts.
    # 
    # @return [::String]
    #   The string by which to split {Const} name and {Bare} name parts of raw 
    #   strings.
    # 
    # @raise [NRSER::AbstractMethodError]
    #   This method **MUST** be overridden with an implementation in realizing
    #   classes.
    # 
    def self.separator
      raise ::NotImplementedError,
        "#{ self.class.name }##{ __method__ } is abstract"
    end
    
    
    # Split a `string` that is a valid for this class into it's {Const} and
    # {Bare} names.
    # 
    # Used in {#initialize} to populate the instance variables backing 
    # {#receiver_name} and {#bare_name}.
    # 
    # @note
    #   This method is only valid when received by {.concrete?} classes, and 
    #   then only for `string` that match their {.pattern}.
    # 
    # @param [::String] string
    #   {::String} to split. Must match this class' {.pattern}.
    # 
    # @return [Array<(Const, Bare)>]
    #   The constant and "bare" name parts of the `string`.
    # 
    def self.split string
      raw_receiver_name, raw_bare_name = string.split separator
      
      [ Const.new( raw_receiver_name ), Bare.new( raw_bare_name ) ]
    end
    
    
    # Name of the constant receiving the method.
    # 
    # @return [NRSER::Meta::Names::Const]
    #     
    attr_reader :receiver_name
    
    
    # Just the bare string name of the method, as you would pass to 
    # {::Object#method} or {::Module#instance_method}.
    # 
    # @return [Bare]
    #     
    attr_reader :bare_name
    
    
    def initialize string
      raw_receiver_name, raw_bare_name = self.class.split string
      
      @receiver_name = Const.new raw_receiver_name
      @bare_name = Bare.new raw_bare_name
      
      super( string )
    end
    
    
    # Get the *implicit* ('.' or '#' prefixed) version of the {#bare_name}.
    # 
    # @return [Implicit]
    #   Realizing classes should return instances of {Implicit} subclasses
    #   ({Method::Singleton} or {Method::Instance}).
    # 
    # @raise [NRSER::AbstractMethodError]
    #   Realizing classes **MUST** override with an implementation.
    # 
    def implicit_name
      raise ::NotImplementedError,
        "#{ self.class.name }##{ __method__ } is abstract"
    end
    
  
    class Singleton < Explicit
      
      # resolves_to_a ::Method
      pattern Const, Method::Singleton
      
      def self.separator
        '.'
      end
      
      def implicit_name
        Method::Singleton.new ".#{ bare_name }"
      end
      
    end # class Singleton
    
    
    class Instance < Explicit
      
      # resolves_to_a ::UnboundMethod
      pattern Const, Method::Instance
      
      def self.separator
        '#'
      end
      
      def implicit_name
        Method::Instance.new ".#{ bare_name }"
      end
      
    end # class Instance
    
  end # class Explicit
  
end # module Method

# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
