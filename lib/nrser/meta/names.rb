# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './names/const'
require_relative './names/method'
require_relative './names/name'
require_relative './names/param'


# Namespace
# =======================================================================

module  NRSER
module  Meta


# Definitions
# =======================================================================

# Contains extensions of {NRSER::String::Patterned} that match various names
# as they appear in Ruby source code.
# 
# Though originally developed to support {NRSER::Described}, designed for 
# general use wherever you need to handle names.
# 
module Names
  
  # Shim for where {NRSER::Strings::Patterned.match} used to be.
  # 
  def self.match *args
    Name.match *args
  end
  
end # module Names


# /Namespace
# =======================================================================

end # module Meta
end # module NRSER
