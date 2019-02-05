# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# {SubjectFrom} is immutable
require 'nrser/props/immutable/instance_variables'

# Need {Described::Base} for prop types
require_relative './base'

# Need {Parameter} for the prop types
require_relative "./subject_from/parameter"


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

# {SubjectFrom} instances encapsulate how {Described::Base} instances can
# resolve their {Described::Base#subject} from other values, either parameters
# the description was initialized with or from subjects or errors of other
# descriptions in the relevant {Hierarchy}.
# 
# @immutable
#
# @note
#   You probably don't want or need to instantiate {SubjectFrom} instances
#   directly unless you are working on the library itself or an extension or
#   something.
#
#   {SubjectFrom} instances are generally declared in description class
#   definitions using the {Described::Base.subject_from} method.
#
class SubjectFrom
  class ExtractError < StandardError; end
  
  
  # Mixins
  # ==========================================================================
  
  include NRSER::Props::Immutable::InstanceVariables
  
  
  # Properties
  # =====================================================================
  
  # Principle Properties
  # ---------------------------------------------------------------------
  
  # @!attribute [r] types
  #   @todo Doc types property...
  #   
  #   @return [Hash<Symbol, Parameter>]
  #   
  prop  :parameters,
        type: t.Hash( keys: t.Symbol, values: Parameter )
  
  
  # @!attribute [r] init_block
  #   @todo Doc init_block property...
  #   
  #   @return [PropRubyType]
  #   
  prop  :block,
        type: t.IsA( Proc )
  
  
  # @todo Document type_for method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.type_for value
    if Described::Base.subclass? value
      t.IsA value
    else
      t.make value
    end
  end # .type_for
  
  
  def initialize parameters:, block:
    initialize_props(
      parameters: parameters.
                          map { |k, v|
                            [ k.to_sym, Parameter.from( v ) ]
                          }.
                          to_h,
      
      block: block,
    )
  end
  
  
end # class SubjectFrom

# /Namespace
# =======================================================================

end # module Described
end # module NRSER
