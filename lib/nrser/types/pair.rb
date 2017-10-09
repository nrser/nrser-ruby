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
  

  # @todo Document pair method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.pair **options
    if options.empty?
      PAIR
    else
      union HASH_PAIR, 
    end
  end # #pair
  
end # module NRSER::Types


# Post-Processing
# =======================================================================
