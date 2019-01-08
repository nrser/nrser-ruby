# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Meta::Names::Const.pattern}
require 'nrser/meta/names'

# Extending in {Helpers}
require_relative './helpers'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Definitions
# =======================================================================

module Instances
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  TODO = \
    Step "I create a new instance of {class} with no parameters" do |class_|
      describe :instance, class_: class_, params: Meta::Params.new
    end
  
end # module Instances

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
