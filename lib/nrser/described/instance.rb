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
  
  from class_: Class, params: Parameters do |class_:, params:|
    params.call class_.method( :new )
  end
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
