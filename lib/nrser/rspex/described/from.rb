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
module  RSpex
module  Described


# Definitions
# =======================================================================

class From < I8::Struct.new \
              types:    t.Hash( keys: t.Symbol, values: t.Type ),
              init_block: t.IsA( Proc )

  def initialize types:, init_block:
    super(
      types:    types.map { |k, v| [ k.to_sym, t.make( v ) ] }.to_h,
      init_block: init_block,
    )
  end
end # class From

# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
