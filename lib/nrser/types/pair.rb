# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './combinators'


# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # @todo Document pair method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def pair **options
      if options.empty?
        PAIR
      else
        union HASH_PAIR, 
      end
    end # #pair
    
  end # class << self (Eigenclass)
  
end # module NRSER::Types


# Post-Processing
# =======================================================================
