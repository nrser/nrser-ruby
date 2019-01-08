# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Error}
require_relative './error'


# Namespace
# =======================================================================

module  NRSER
module  Described
class   Resolution


# Definitions
# =======================================================================

# Raised by {Base#subject} when no subject has been resolved.
# 
# This means either:
# 
# 1.  The {Described::Base} subclass was constructed improperly.
#     
# 2.  {Described::Base#resolve!} should have been called before the call
#     to {#subject}.
# 
class UnresolvedError < Error

  # @return [String]
  def default_message
    "Subject has not been defined, must be set or resolved"
  end
  
end # class UnresolvedError


# /Namespace
# =======================================================================

end # class Resolution
end # module Described
end # module NRSER
