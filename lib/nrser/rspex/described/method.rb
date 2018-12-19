# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Callable}
require_relative './callable'

# Describes {Instance}
require_relative './instance'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described


# Definitions
# =======================================================================

# Abstract base class for all {NRSER::RSpex} description objects.
# 
# Description objects formalize and extend {RSpec}'s explicit subject 
# functionality.
# 
# @abstract
# 
class Method < Callable
  
  # Config
  # ========================================================================
  
  subject_type ::Method
  
  from instance: Instance, unbound_method: UnboundMethod \
  do |instance:, unbound_method:|
    unbound_method.bind instance
  end
  
  from object: Object, :@name => self.Names::Method do |object:, name:|
    object.method name
  end
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
