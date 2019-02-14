# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Object}
require_relative "./object"


# Namespace
# =======================================================================

module  NRSER
module  Described


# Refinements
# ============================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Definitions
# =======================================================================

# @todo doc me!
# 
class Instance < Object
  
  # Config
  # ========================================================================
  
  # TODO  *Should* be possible to make this enforce that {#subject} is an
  #       instance of `#values[ :class_ ]`..? Would be sweet...
  #       
  subject_type ::Object
  
  subject_from \
    class_: Class, 
    method_name: t.maybe( Meta::Names::Method::Bare ),
    params: Parameters do |class_:, method_name:, params:|
    params.call class_.method( method_name || :new )
  end
  
  
  subject_from object: ::Object do |object:|
    object
  end
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
