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


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Sys


# Definitions
# =======================================================================

# Regular expression for detecting Unix-like platforms in `RUBY_PLATFORM`.
# 
# @return [Regexp]
# 
PLATFORM_UNIX_RE = \
  /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i


# Are we on a Unix-like platform?
# 
# @return [Boolean]
# 
def self.unix? platform_string = RUBY_PLATFORM
  !!( platform_string =~ PLATFORM_UNIX_RE )
end


# /Namespace
# =======================================================================

end # module Sys
end # module NRSER
