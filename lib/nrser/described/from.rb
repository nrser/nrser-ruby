# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/labs/i8/struct'


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

class From < I8::Struct.new \
              types:    t.Hash( keys: t.Symbol, values: t.Type ),
              init_block: t.IsA( Proc )
  
  # @todo Document type_for method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.type_for value
    if Base.subclass? value
      t.IsA value
    else
      t.make value
    end
  end # .type_for
  
  def initialize types:, init_block:
    super(
      types:      types.
                    map { |k, v| [ k.to_sym, self.class.type_for( v ) ] }.
                    to_h,
      init_block: init_block,
    )
  end
end # class From

# /Namespace
# =======================================================================

end # module Described
end # module NRSER
