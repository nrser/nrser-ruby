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


# Declarations
# =======================================================================


# Definitions
# =======================================================================

# @todo document NRSER::RSpex::Described::Class class.
class NRSER::RSpex::Described::Class < NRSER::RSpex::Described
  def initialize ref, parent: nil
    super ref, type: :class, parent: parent
  end
  
  
  def to_desc
    
  end
end # class NRSER::RSpex::Described::Class
