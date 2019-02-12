# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

### Deps ###

# Not sure if I want all of AS's Module stuff, but def want 
# {::Module#anonymous?}
require 'active_support/core_ext/module/anonymous'

### Project / Package ###

# Submodules
require_relative './module/method_objects'
require_relative './module/names'
require_relative './module/source_locations'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions for {::Module}.
# 
module Module
  
  refine ::Module do
    prepend Ext::Module
  end

end # module Module


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER

