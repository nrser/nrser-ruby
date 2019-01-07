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

# Don't load pryrc - we went the env exactly how it is, and there's a huge mess
# of shit in there
Pry.config.should_load_rc = false

NRSER::Log.setup_for_cucumber!


After &->( scenario ) do
  binding.pry if scenario.failed?
end
