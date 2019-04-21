# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Object}
require_relative "./object"

# Describes {Callable}
require_relative './callable'

# Describes {Params}
require_relative './arguments'

# Describes {Instance}
require_relative './instance'

# Describes {InstanceMethod}
require_relative './instance_method'

# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

class Response < Object

  # Config
  # ========================================================================
  
  subject_type ::Object
  
  subject_from callable: Callable, args: Arguments do |callable:, args:|
    args.call callable
  end
  
  subject_from \
    instance: Instance,
    instance_method: InstanceMethod,
    args: Arguments \
  do |instance:, instance_method:, args:|
    args.call instance_method.bind( instance )
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
