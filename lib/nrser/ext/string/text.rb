# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/functions/text'


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
  
  # Calls {NRSER.find_indent} on `self`.
  def find_indent
    NRSER.find_indent self
  end
  
  
  # Calls {NRSER.indented?} on `self`.
  def self.indented?
    NRSER.indented? self
  end


  # Calls {NRSER.dedent} on `self`.
  def dedent *args
    NRSER.dedent self, *args
  end


  # Calls {NRSER.dedent} on `self`.
  def deindent *args
    NRSER.dedent self, *args
  end
  

  # Calls {NRSER.indent} on `self`.
  def indent *args
    NRSER.indent self, *args
  end


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
