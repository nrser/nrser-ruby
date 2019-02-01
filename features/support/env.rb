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

# Using truthy to test ENV vars
require 'nrser/ext/object/booly'


# Config
# =======================================================================

# Don't load pryrc - we went the env exactly how it is, and there's a huge mess
# of shit in there
Pry.config.should_load_rc = false

NRSER::Log.setup_for_cucumber!

unless ENV[ "FULL_TRACES" ].truthy?
  # Clean backtraces to make them easier to read
  
  require "nrser/ext/exception"

  NRSER::Ext::Exception.backtrace_cleaner = \
    { rel_paths: true, silence_gems: true }
end

After &->( scenario ) do
  if scenario.failed?
    # binding.pry
  end
end
