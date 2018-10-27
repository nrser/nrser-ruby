# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------
require 'time'

# Deps
# ------------------------------------------------------------------------

require 'active_support/core_ext/time'

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/ext/time'


# Definitions
# =======================================================================

class Time
  prepend NRSER::Ext::Time
end
