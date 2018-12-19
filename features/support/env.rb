# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

# Debug with `binding.pry`
require 'pry'

# Project / Package
# -----------------------------------------------------------------------

require 'nrser'

# Using {String#~} to squish string blocks
require 'nrser/core_ext/string/squiggle'


# Config
# =======================================================================

NRSER::Log.setup_for_cucumber!
