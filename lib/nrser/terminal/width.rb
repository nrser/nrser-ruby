# encoding: UTF-8
# frozen_string_literal: true

##############################################################################
# Dynamic Terminal Width Detection for Unix-Like Systems
# ============================================================================
#
# Code adapted from [Thor][]'s [Thor::Shell::Basic][] module, copyright (c) 2008
# Yehuda Katz, Eric Hodel, et al., and [available under the MIT license][Thor
# license].
#
# Portions of *that* code are copied from [Rake][], copyright (c) 2003, 2004 Jim
# Weirich, also [available under the MIT license][Rake license].
#
# [Thor]: http://whatisthor.com/
# [Thor::Shell::Basic]: https://www.rubydoc.info/github/wycats/thor/Thor/Shell/Basic
# [Thor license]: https://github.com/erikhuda/thor/blob/master/LICENSE.md
# [Rake]: https://github.com/ruby/rake
# [Rake license]: https://github.com/ruby/rake/blob/master/MIT-LICENSE
#
##############################################################################

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/sys/unix'


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Terminal


# Definitions
# =======================================================================

# Constants
# ----------------------------------------------------------------------------

# Default to return from {.width} if {.dynamic_width} is unavailable.
# 
# @return [Integer]
# 
DEFAULT_WIDTH = 80

DYNAMIC_WIDTH_CUTOFF = 10


# @!group Terminal Width Class Methods
# ----------------------------------------------------------------------------

# Returns the width of the terminal, or {DEFAULT_WIDTH} if it can't be
# determined or is less than the {DYNAMIC_WIDTH_CUTOFF}.
#
# If anything raises, returns {DEFAULT_WIDTH}.
#
# On platforms that are not Unix-like always returns {DEFAULT_WIDTH} (see
# {Sys.unix?}).
#
# @note 
#   Adapted from Thor (MIT), which copied it from Rake (MIT) (see copyright
#   and license notice at top of file), so I'm not sure how robust it is,
#   especially since it swallows all errors to return {DEFAULT_WIDTH}.
#
# @return [Integer]
#   Should always be at least as large as the smallest of {DEFAULT_WIDTH} and 
#   {DYNAMIC_WIDTH_CUTOFF}.
#
def self.width
  return DEFAULT_WIDTH unless Sys.unix?

  dynamic_width = self.dynamic_width

  if dynamic_width < DYNAMIC_WIDTH_CUTOFF
    DEFAULT_WIDTH
  else
    dynamic_width
  end
rescue
  DEFAULT_WIDTH
end # .width


# Calculate the dynamic width of the terminal.
# 
# First tries {.dynamic_width_stty}, then {.dynamic_width_tput} if that returns
# `0`.
# 
# @note
#   Copied from Thor (MIT), which may have copied it from Rake (see notice at 
#   top of file). Thor had no documentation on return types or error conditions,
#   so I'm not really sure what is supposed to or does happen when something 
#   goes wrong.
# 
def self.dynamic_width
  dynamic_width_stty.nonzero? || dynamic_width_tput
end


# Calculate the width by calling the `stty` system command and parsing result.
# 
# Copied from Thor, copyright (c) 2008 Yehuda Katz, Eric Hodel, et al. (MIT 
# license).
# 
# @return [Integer]
# 
def self.dynamic_width_stty
  `stty size 2>/dev/null`.split[1].to_i
end


def self.dynamic_width_tput
  `tput cols 2>/dev/null`.to_i
end

# @!endgroup Terminal Width Class Methods # **********************************


# /Namespace
# =======================================================================

end # module Terminal
end # module NRSER
