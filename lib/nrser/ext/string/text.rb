# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/functions/text'

require_relative './text/ellipsis'
require_relative './text/smart_ellipsis'
require_relative './text/indentation'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module String
  
  # Instance Methods
  # ========================================================================

  # @!group Text Manipulation Instance Methods
  # --------------------------------------------------------------------------


  # Calls {NRSER.word_wrap} on `self`.
  def word_wrap *args
    NRSER.word_wrap self, *args
  end


  # Calls {NRSER.words} on `self`
  def words
    NRSER.words self
  end

  # @!endgroup Text Manipulation Instance Methods # **************************

end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
