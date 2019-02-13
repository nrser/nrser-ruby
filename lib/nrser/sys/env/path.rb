# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/argument_error'
require 'nrser/errors/type_error'


# Refinements
# ============================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Declarations
# =======================================================================


# Definitions
# =======================================================================

# @todo document NRSER::Env::Path class.
class NRSER::Sys::Env::Path
  include Enumerable
  
  # Constants
  # ======================================================================
  
  # Character used to separate path entries in string format.
  # 
  # @return [String]
  # 
  SEPARATOR = ':'
  
  
  # Class Methods
  # ======================================================================
  
  # @todo Document normalize method.
  # 
  # @param [nil | String | #each_index] source
  #   Path source.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.normalize source
    
    paths = t.match source,
      t.Nil, [],
      
      t.String, ->( string ) {
        string.split SEPARATOR
      },
      
      t.array_like, ->( array_like ) {
        # Flatten it if supported
        array_like = array_like.flatten if array_like.respond_to?( :flatten )
        
        # Stringify each segment, split them and concat results
        array_like.flat_map { |entry| entry.to_s.split SEPARATOR }
      }
    
    Hamster::Vector.new paths.
      # Get rid of empty paths
      reject( &:empty? ).
      # Get rid of duplicates
      uniq.
      # Freeze all the strings
      map( &:freeze )
      
  end # .normalize
  
  
  # See if a `path` matches any of `patterns`.
  # 
  # Short-circuits as soon as a match is found (so patterns may not all be
  # tested).
  # 
  # @param [String] path
  #   Path to test against.
  # 
  # @param [Array<String | Proc<String=>Boolean> | Regexp>] patterns
  #   Patterns to test:
  #   
  #   -   `String` - test if it and `path` are equal (`==`)
  #       
  #   -   `Proc<String=>Boolean>` - call with `path` and evaluate result as
  #       Boolean.
  #       
  #   -   `Regexp` - test if it matches `path` (`=~`)
  # 
  # @return [Boolean]
  #   `true` if *any* of `patterns` match `path`.
  # 
  def self.matches_pattern? path, *patterns
    patterns.any? do |pattern|
      case pattern
      when String
        path == pattern
      when Proc
        pattern.call path
      when Regexp
        path =~ pattern
      else
        raise NRSER::TypeError.new \
          "Each `*patterns` arg should be String, Proc or Regexp",
          bad_pattern: pattern,
          patterns: patterns
      end
    end
  end # .matches_pattern?
  
  
  def self.from_ENV env_key
    new ENV[env_key.to_s], env_key: env_key
  end # .from_env
  
  
  # Attributes
  # ======================================================================
  
  # Key for the value in `ENV` that the object represents. This is set when
  # loading from `ENV` and used to know where to write when saving back to it.
  # 
  # @return [nil | String]
  #     
  attr_reader :env_key
  
  
  # The object that was originally provided at construction.
  # 
  # @return [nil | String | #each_index]
  #     
  attr_reader :source
  
  
  # The actual internal list of paths.
  # 
  # @return [Hamster::Vector<String>]
  #     
  attr_reader :value
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Env::Path`.
  def initialize source, env_key: nil
    @env_key = env_key.to_s.freeze
    @source = source.dup.freeze
    @value = self.class.normalize source
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  # 
  # @param source (see .normalize)
  # @return [self]
  # 
  def prepend source
    # Normalize the new source to a flat array of strings
    paths = self.class.normalize source
    
    # The new value is the normalized paths followed by the current paths
    # with the new ones removed (de-duplication)
    @value = (paths + @value).uniq
    
    # Return self for chain-ability
    self
  end
  
  alias_method :unshift, :prepend
  alias_method :>>, :prepend
  
  
  # 
  # @param source (see .normalize)
  # @return [self]
  # 
  def append source
    # Normalize the new source to a flat array of strings
    paths = self.class.normalize source
    
    # The new value is the current paths with the new paths appended, with
    # any paths in the current path removed from the new ones (de-duplication)
    @value = (@value + paths).uniq
    
    # Return self for chain-ability
    self
  end
  
  alias_method :push, :prepend
  alias_method :<<, :prepend
  
  
  def insert source, before: nil, after: nil
    paths = self.class.normalize source
    
    before_index = if before
      @value.find_index do |path|
        self.class.matches_pattern? path, *before
      end
    end
    
    after_index = if after
      index = @value.rindex { |path| self.class.matches_pattern? path, *after }
      index += 1 if index
    end
    
    insert_index = if after_index && before_index
      # Make sure the conditions don't conflict with each other
      if after_index > before_index
        raise "Conflicting bounds!"
      end
      
      # Insert as far "down" the path as allowed
      [before_index, after_index].max
    else
      # Use the one that is not `nil`, or insert at the end if they both are
      before_index || after_index || @value.length
    end
    
    @value = @value.insert( insert_index, *paths ).uniq
    
    self
  end
  
  
  # Language Interop
  # ============================================================================
  
  # Support for {Enumerable} mixin. Yields each path in order.
  # 
  # Specifically, proxies to {Hamster::Vector#each}
  # 
  # @see http://www.rubydoc.info/gems/hamster/Hamster/Vector#each-instance_method
  # 
  # @param [nil | Proc<(String)=>*>] block
  #   When present, block will be called once for each string path in this
  #   object. First path is most prominent, down to least last.
  # 
  # @return [self]
  #   When `&block` is provided.
  # 
  # @return [Enumerator]
  #   When `&block` is omitted.
  # 
  def each &block
    if block
      # Proxy for yielding
      @value.each &block
      
      # Return self for chain-ability
      self
    else
      # Return the {Enumerator} from the vector
      @value.each
    end
  end # #each
  
  
  # The paths joined with ':'.
  # 
  # @return [String]
  # 
  def to_s
    @value.join SEPARATOR
  end
  
  
  # The string paths in a new stdlib `Array`. Mutating this array will have no
  # effect on the {NRSER::Env::Path} data.
  # 
  # @return [Array<String>]
  # 
  def to_a
    @value.to_a
  end
  
  
end # class NRSER::Env::Path
