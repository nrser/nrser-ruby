# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::Class#subclasses}
require 'active_support/core_ext/class/subclasses'

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Regexp::Composed.or}
require 'nrser/regexp/composed'

require_relative './described/base'
require_relative './described/class'
require_relative './described/method'
require_relative './described/module'
require_relative './described/object'
require_relative './described/response'



# Namespace
# ========================================================================

module  NRSER
module  RSpex


# Definitions
# =======================================================================

module Described
  def self.human_name_pattern full: false, options: nil
    NRSER::Regexp::Composed.or \
      *Base.descendants.flat_map { |cls|
        cls.human_names.map { |human_name| ::Regexp.escape human_name }
      },
      full: full,
      options: options
  end
end # module Described


# /Namespace
# ========================================================================

end # module RSpex
end # module NRSER
