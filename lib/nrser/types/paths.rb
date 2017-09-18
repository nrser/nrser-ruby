# Requirements
# =======================================================================

# stdlib
require 'pathname'

# gems

# package
require_relative './is_a'
require_relative './where'
require_relative './combinators'


# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  # A {Pathname} type that provides a `from_s` 
  PATHNAME = is_a \
    Pathname,
    name: 'PathnameType',
    from_s: ->(string) { Pathname.new string }
  
  
  # A type satisfied by a {Pathname} instance that's not empty (meaning it's
  # string representation is not empty).
  NON_EMPTY_PATHNAME = intersection \
    PATHNAME,
    where { |value| value.to_s.length > 0 },
    name: 'NonEmptyPathnameType'
  
  
  PATH = union non_empty_str, NON_EMPTY_PATHNAME
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # @todo Document path method.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def path **options
      if options.empty?
        PATH
      else
        union non_empty_str, NON_EMPTY_PATHNAME, **options
      end
    end # #path
    
  end # class << self (Eigenclass)
  
end # module NRSER::Types

