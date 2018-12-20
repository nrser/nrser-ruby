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

# Using {NRSER::Regexp::Composed.join} and {NRSER::Regexp::Composed.or} to
# compose {Names::Name.pattern} instances.
require 'nrser/regexp/composed'


# Refinements
# =======================================================================

require 'nrser/refinements/sugar'
using NRSER::Sugar


# Namespace
# =======================================================================

module  NRSER
module  Meta


# Definitions
# =======================================================================


# @todo document Names module.
module Names
  
  
  def self.match value, *clauses
    NRSER::Types.match \
      value,
      *clauses.
        each_slice( 2 ).
        flat_map { |(type, proc)|
          if Name.name_subclass? type
            [ type, ->( object ) { proc.call type.new( object ) } ]
          else
            [ type, proc ]
          end
        }
  end
  
  
  # Abstract base class for Ruby constant and method name strings.
  # 
  # @abstract
  # 
  class Name < ::String
    
    # Singleton Methods
    # ========================================================================
    
    
    def self.re
      NRSER::Regexp::Composed
    end
    
    
    # Create a {NRSER::Types::Type} representing the name.
    # 
    # The type tests if value's string representations (`#to_s` response)
    # matched {.pattern}.
    # 
    # @return [NRSER::Types::Type]
    # 
    def self.to_type
      NRSER::Types.Respond( to: :to_s, with: pattern )
    end
    
    
    # Returns the {.pattern}.
    # 
    # Used by {NRSER::Regexp::Composed} when composing.
    # 
    # @return [::Regexp]
    # 
    def self.to_re
      pattern
    end
    
    
    # Safe test if `object` is a subclass of {Name}.
    # 
    # @param [::Object] object
    #   Any {::Object}.
    # 
    # @return [Boolean]
    #   `true` if `object` is a {::Class} and a *proper* subclass of {Name}.
    # 
    def self.name_subclass? object
      object.is_a?( ::Class ) && object < Name
    end
    
    
    # Declare or read the {::Regexp} pattern used to test strings for 
    # membership.
    # 
    # @overload pattern
    #   Get the class' {::Regexp} pattern used to test strings for membership.
    # 
    #   @return [::Regexp]
    #     Regular expression that all instances must match.
    #   
    #   @raise [NRSER::RuntimeError]
    #     If this class does not have a pattern declared. This means the class 
    #     is either:
    #     
    #     1.  Abstract, and can not be instantiated.
    #     2.  Misconfigured.
    # 
    # @overload pattern *objects
    #   Declare the class' {::Regexp} pattern used to test strings for 
    #   membership.
    #   
    #   The pattern may be set only once, and should be done in the class 
    #   definition.
    #   
    #   `objects` entries that are {Name} subclasses are converted to their
    #   {.pattern}, and all entries are joined and made to match full strings
    #   using {NRSER::Ext::Regexp.join}.
    #   
    #   @see NRSER::Ext::Regexp.join
    # 
    #   @param [::Array<::Class<Name>, ::Regexp, ::String, #to_s>] objects
    #     Objects to join into the class' pattern.
    #       
    #   @return [::Regexp]
    #     The pattern.
    #   
    #   @raise [NRSER::ConflictError]
    #     If a pattern has already been declared for this class.
    # 
    def self.pattern *objects
      unless objects.empty?
        if @pattern.is_a? ::Regexp
          raise NRSER::ConflictError.new \
            "`#{ name }.pattern` is already set to", @pattern
        end
        
        @pattern = if objects.length == 1 &&
                      objects[0].is_a?( NRSER::Regexp::Composed )
          if objects[0].full?
            objects[0]
          else
            objects[0].to_full
          end
        else
          re.join \
            *objects.map { |object|
              if name_subclass?( object ) then object.pattern else object end
            },
            full: true
        end
      end
      
      unless @pattern.is_a? ::Regexp
        raise NRSER::RuntimeError.new \
          self, "has no `.pattern` setup, which means it is abstract or ",
          "incorrectly configured."
      end
      
      @pattern
    end # .pattern
    
    
    def self.| other
      NRSER::Regexp::Composed.or self, other
    end
    
    
    def self.+ other
      NRSER::Regexp::Composed.join self, other
    end
    
    
    # Construct a new name instance.
    # 
    # `object` parameter is converted to a {::String} via `#to_s`.
    # and checked against the class' {.pattern}.
    # 
    # @param [#to_s] object
    #   String representation becomes the object.
    # 
    # @return
    #   New instance of the name class.
    # 
    # @raise [NRSER::ArgumentError]
    #   If the string representation of the `object` parameter does not match
    #   the class' {.pattern}.
    # 
    def self.new object
      string = object.to_s
      
      unless pattern =~ string
        raise NRSER::ArgumentError.new \
          self, "can only be constructed of strings that match", pattern,
          string: string,
          pattern: pattern
      end
      
      super( string )
    end # .new
    
  end # class Name
  
  
  class ModuleConst < Name
    pattern /\A[A-Z_][A-Za-z0-9]*\z/
  end
  
  
  # Name of a module, as returned by {::Module.name}.
  # 
  # @example
  #   name = NRSER::Meta::Names::Module.new 'NRSER::Ext::Regexp'
  #   #=> "NRSER::Ext::Regexp"
  #   
  #   name.class
  #   #=> NRSER::Meta::Names::Module
  #   
  #   name.const_names
  #   #=> ["NRSER", "Ext", "Regexp"]
  #   
  #   name.top_level?
  #   #=> false
  # 
  # @example Top-level name
  #   name = NRSER::Meta::Names::Module.new '::NRSER::Ext::Regexp'
  #   #=> "::NRSER::Ext::Regexp"
  #   
  #   name.const_names
  #   #=> ["NRSER", "Ext", "Regexp"]
  #   
  #   name.top_level?
  #   #=> true
  # 
  class Module < Name
    
    pattern \
      re.maybe( '::' ),
      ModuleConst,
      re.any( re.join( '::', ModuleConst) )
    # [:+, [:_?, '::'], ModuleConst, [:*, [:+, '::', ModuleConst ]]]
    # [ [ :_?, '::' ], ModuleConst, [ :*, [ '::', ModuleConst ] ] ]
    
    
    # TODO document `const_names` attribute.
    # 
    # @return [NRSER::Meta::Names::ModuleConst]
    #     
    attr_reader :const_names
    
    
    # TODO document `is_top_level` attribute.
    # 
    # @return [Boolean]
    #     
    attr_reader :is_top_level
    
    
    def initialize string
      strings = string.split '::'
      
      @is_top_level = if strings.first.empty?
        strings.shift
        true
      else
        false
      end
      
      @const_names = strings.map &ModuleConst.method( :new )
      
      super( string )
    end # #initialize
    
    def top_level?; is_top_level end
    
    def to_h
      {
        const_names: const_names,
        is_top_level: is_top_level,
      }
    end
  end
  
  
  # @note
  #   Instance variables names *can* start with or be all capital letters,
  #   and at least `attr_accessor` seems to work fine with it, which makes sense
  #   since method names can be caps too.
  #   
  #   Check this shit...
  #   
  #   ```Ruby
  #   class BadAttr
  #     attr_accessor :BAD
  #   
  #     def initialize bad
  #       @BAD = bad
  #     end
  #   end
  #   
  #   bad = BadAttr.new 'bad...'
  #   bad.BAD
  #   #=> "bad..."
  #   
  #   bad.BAD = 'worse!'
  #   bad.BAD
  #   #=> "worse!"
  #   ```
  #   
  #   Ok, calm down. I don't want to lose my developer's license, so, please,
  #   everyone repeat after me: "Just because you *can*, doesn't mean you..."
  #   
  class InstanceVariable < Name
    pattern /\A@[A-Za-z_][A-Za-z0-9_]*\z/
  end
  
  
  class Variable < Name
    pattern /\A[a-z_][A-Za-z0-9_]*\z/
  end
  
  
  # Parameter Names
  # ============================================================================
  
  # Abstract base class for parameter names, defining the interface.
  # 
  # @abstract
  # 
  class BaseParam < Name
    
    # The part of the parameter name that is used as the variable name (which
    # may be the whole thing, as in {PositionalParam}).
    # 
    # @return [Variable]
    #     
    attr_reader :var_name
    
    
    def var_sym
      var_name.to_sym
    end
    
  end
  
  
  class PositionalParam < BaseParam
    pattern Variable
    
    def initialize string
      @var_name = Variable.new string
      super( string )
    end
  end
  
  
  class KeywordParam < BaseParam
    pattern Variable, re.esc( ':' )
    
    def initialize string
      @var_name = Variable.new string[ 0..-2 ]
      super( string )
    end
  end
  
  
  class BlockParam < BaseParam
    pattern re.esc( '&' ), Variable
    
    def initialize string
      @var_name = Variable.new string[ 2..-1 ]
      super( string )
    end
  end
  
  
  class RestParam < BaseParam
    pattern re.esc( '*' ), Variable
    
    def initialize string
      @var_name = Variable.new string[ 2..-1 ]
      super( string )
    end
  end
  
  
  class KeyRestParam < BaseParam
    pattern re.esc( '**' ), Variable
    
    def initialize string
      @var_name = Variable.new string[ 3..-1 ]
      super( string )
    end
  end
  
  
  class Param < Name
    # pattern PositionalParam | KeywordParam | BlockParam
    pattern \
      re.or(
        PositionalParam,
        KeywordParam,
        BlockParam,
        RestParam,
        KeyRestParam,
        full: true
      )
  end
  
  
  # Method Names
  # ==========================================================================
  
  class OperatorMethod < Name
    pattern \
      re.or(
        *%w([] []= ** ~ ~ @+ @- * / % + - >> << & ^ | <= < > >= <=> == === != =~ !~).
          map { |s| re.esc s },
        full: true
      )
  end
  
  
  class Method < Name
    pattern \
      re.or( OperatorMethod, /\A[A-Za-z_][a-zA-Z0-9_]*[\?\!]?\z/, full: true )
    
    def method_name
      self
    end
  end
  
  
  class Attribute < Method
    pattern Method
  end
  
  
  # Abstract base class for method names prefixed by `.` or `#` to indicating
  # they are singleton or instance methods, respectively.
  #
  # @abstract @see SingletonMethod @see InstanceMethod
  #
  class PrefixedMethod < Name
    
    # Just the name of the method.
    # 
    # @return [NRSER::Meta::Names::Method]
    #     
    attr_reader :method_name
    
    
    def initialize string
      @method_name = Method.new string[ 1..-1 ]
      
      super( string )
    end
    
    
    def to_h
      { method_name: method_name }
    end
    
  end # class ImplicitMethod
  
  
  class SingletonMethod < PrefixedMethod
    pattern re.esc( '.' ), Method
  end
  
  
  class InstanceMethod < PrefixedMethod
    pattern re.esc( '#' ), Method
  end
  
  
  # Abstract base class for {QualifiedSingletonMethod} and
  # {QualifiedInstanceMethod}.
  #
  # @abstract
  #
  class QualifiedMethod < Name
    
    # Name of the {::Module} owning the singleton method.
    # 
    # @return [NRSER::Meta::Names::Module]
    #     
    attr_reader :module_name
    
    
    # Bare name of the singleton method itself.
    # 
    # @return [NRSER::Meta::Names::Method]
    #     
    attr_reader :method_name
    
    
    def initialize string
      raw_module_name, raw_method_name = string.split( self.class::SEPARATOR )

      @module_name = Module.new raw_module_name
      @method_name = Method.new raw_method_name
      
      super( string )
    end
    
    
    def to_h
      {
        module_name: module_name,
        method_name: method_name,
      }
    end
    
  end # class QualifiedMethod
  
  
  # A coupled {NRSER::Meta::Names::Module} name and {SingletonMethod} name.
  # 
  class QualifiedSingletonMethod < QualifiedMethod
    SEPARATOR = '.'
    
    pattern Module, SingletonMethod
  end
  
  
  # A coupled {NRSER::Meta::Names::Module} name {QualifiedInstanceMethod} name.
  # 
  class QualifiedInstanceMethod < QualifiedMethod
    SEPARATOR = '#'
    
    pattern Module, InstanceMethod
  end
  
end # module Names


# /Namespace
# =======================================================================

end # module Meta
end # module NRSER
