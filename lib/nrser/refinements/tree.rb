# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Declarations
# =======================================================================

module NRSER; end
module NRSER::Refinements; end


# Definitions
# =======================================================================

# Instance methods that are refined in to the Ruby built-ins that we consider
# trees: {Array}, {Hash} and {OpenStruct}.
# 
module NRSER::Refinements::Tree
  
  # Sends `self` to {NRSER.leaves}.
  def leaves
    NRSER.leaves self
  end # #leaves
  
  
  # Sends `self` and the optional `block` to {NRSER.each_branch}.
  def each_branch &block
    NRSER.each_branch self, &block
  end
  
end # module NRSER::Refinements::Tree

