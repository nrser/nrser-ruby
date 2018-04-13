# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/types/type'
require 'nrser/types/combinators'


# Definitions
# =======================================================================

module NRSER::Types
  class Type
    
    def | other
      NRSER::Types.union self, NRSER::Types.make( other )
    end
    
  end # Type
end # NRSER::Types
