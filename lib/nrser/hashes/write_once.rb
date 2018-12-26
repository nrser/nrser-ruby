# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/labs/stash'


# Namespace
# =======================================================================

module  NRSER
module  Hashes


# Definitions
# =======================================================================

# @todo document WriteOnce class.
class WriteOnce < Stash
  
  # Instance Methods
  # ========================================================================
  
  def put key, value
    if key? key
      raise NRSER::KeyError,
        "Key", key, "already set",
        key: key,
        current_value: self[ key ],
        provided_value: value
    end
    
    super( key, value )
  end
  
end # class WriteOnce


# /Namespace
# =======================================================================

end # module Hashes
end # module NRSER
