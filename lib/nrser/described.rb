# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::Class#descendants}
require 'active_support/core_ext/class/subclasses'

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Regexps::Composed.or}
require 'nrser/regexps/composed'

require_relative './described/base'
require_relative './described/class'
require_relative './described/method'
require_relative './described/module'
require_relative './described/object'
require_relative './described/response'



# Namespace
# ========================================================================

module  NRSER


# Definitions
# =======================================================================

module Described
  def self.human_name_pattern full: false, options: nil
    NRSER::Regexps::Composed.or \
      *Base.descendants.flat_map { |cls|
        cls.human_names.map { |human_name| ::Regexp.escape human_name }
      },
      full: full,
      options: options
  end
end # module Described


# /Namespace
# ========================================================================

end # module NRSER
