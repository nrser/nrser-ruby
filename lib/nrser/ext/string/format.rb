# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Deps
# ------------------------------------------------------------------------

# Using {String#constantize}, {String#safe_constantize}
require 'active_support/core_ext/string/inflections'

# Using {String#squish}
require 'active_support/core_ext/string/filters'



# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module String

  # Constants
  # ==========================================================================
  
  # @!group Format Constants
  # --------------------------------------------------------------------------

  # Regular expression used to match whitespace.
  # 
  # @return [Regexp]
  # 
  WHITESPACE_RE = /\A[[:space:]]*\z/

  # @!endgroup Format Constants # ********************************************

  
  # Instance Methods
  # ========================================================================

  # @!group Format Instance Methods
  # --------------------------------------------------------------------------
  
  # Is this string all whitespace?
  # 
  # Uses {WHITESPACE_RE} to test, which in turn uses the `[[:space:]]` *POSIX
  # bracket expression*.
  # 
  # @see https://ruby-doc.org/core-2.3.0/Regexp.html
  # 
  # @return [Boolean]
  # 
  def whitespace?
    self =~ WHITESPACE_RE
  end

  # @!endgroup Format Instance Methods # *************************************
  
end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
