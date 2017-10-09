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

require 'nrser/refinements'
using NRSER


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  # A label is a non-empty {String} or {Symbol}.
  # 
  # @param [Hash] **options
  #   Options to pass to {NRSER::Types::Type#initialize}.
  # 
  # @return [NRSER::Types::Type]
  # 
  def self.label **options
    if options.empty?
      LABEL
    else
      union t.non_empty_str, t.sym, **options
    end
  end # .label
  
  LABEL = label( name: 'LabelType' ).freeze
  
end # module NRSER::Types
