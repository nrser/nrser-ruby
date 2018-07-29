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

require_relative './combinators'
require_relative './when'
require_relative './shape'

# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

def_factory :selector,
  aliases:  [ :query, :[] ] \
do |pairs, **options|
  shape \
    pairs.transform_values { |value|
      if value.is_a?( Type )
        value
      else
        self.or(
          self.when( value ),
          (bag & has( value )),
          name: "{#{ value.inspect  }}"
        )
      end
    },
    **options
end


# /Namespace
# =======================================================================

end # module Types
end # module NRSER

