# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Submodules
require_relative './example/logger'



# Namespace
# ========================================================================

module  NRSER
module  RSpex


# Definitions
# =======================================================================

# Extensions available in examples themselves via RSpec's `config.include`.
# 
module Example
  include Logger
  
  def described_class
    self.class.metadata[:class] || super
  end


  def described_module
    self.class.described_module
  end
  
  
  def described_constructor_args
    self.class.described_constructor_args
  end
  
  
  # HACK HACK HACK-ITY HACK
  # 
  # Hook used to `#extend` `base` with
  # {NRSER::RSpex::ExampleGroup::Overrides}, see discussion/confession
  # over there.
  # 
  # @param [Class] base
  #   The class this mixin got included in.
  # 
  # @return [void]
  # 
  def self.included base
    base.extend NRSER::RSpex::ExampleGroup::Overrides
  end
  
end # module Example


# /Namespace
# ========================================================================

end # module RSpex
end # module NRSER
