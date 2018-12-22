# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Error}
require_relative './error'


# Refinements
# ========================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
class   Resolution


# Definitions
# =======================================================================

# Raised by {Base#resolve_subject!} when all {Resolution}s have failed, and
# therefor a {Base#subject} could not be produced.
# 
# This means either:
# 
# 1.  The description hierarchy is misformed.
# 2.  There is a bug.
# 
class AllFailedError < Error
  
  # @!method resolutions
  #   {::Array} of {Resolution} instances that were attempted.
  #   
  #   @return [Array<Resolution>]
  # 
  def_context_delegator \
    keys: :resolutions,
    presence_predicate: false
  
  
  # Construct a new {AllFailedError}. Checks that the `resolutions:` keyword
  # is an {::Array} of {::Resolution}.
  # 
  # @param (see NRSER::NicerError#initialize)
  # 
  # @param [::Array<Resolution>] resolutions
  #   Attempted {Resolution}s.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If `resolutions:` is not the correct type.
  # 
  def initialize *message, resolutions:, **kwds
    t.Array( Resolution ).check! resolutions
    
    super( *message, resolutions: resolutions, **kwds )
  end
  
end # class AllFailedError


# /Namespace
# =======================================================================

end # class Resolution
end # module Described
end # module NRSER
