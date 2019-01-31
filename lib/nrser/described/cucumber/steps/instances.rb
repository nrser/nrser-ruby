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
  
  CREATE_A_NEW_INSTANCE,
  CONSTRUCT_AN_INSTANCE = \
    [
      "I create a new instance of {class}",
      "I construct an instance of {class}",
    ].map do |template|
      Step template do |class_|
        describe :instance, class_: class_
      end
    end
  
  
  CREATE_A_NEW_INSTANCE_OF_THE_DESCRIBED,
  CONSTRUCT_AN_INSTANCE_OF_THE_DESCRIBED = \
    [
      "I create a new instance of the {described}",
      "I construct an instance of the {described}",
    ].map do |template|
      Step template do |described|
        describe :instance, class_: described.resolve!( hierarchy ).subject
      end
    end
  
  
  CREATE_A_NEW_INSTANCE_OF_THE_DESCRIBED_FROM,
  CONSTRUCT_AN_INSTANCE_OF_THE_DESCRIBED_FROM = \
    [
      "I create a new instance of the {described} from {values}",
      "I construct an instance of the {described} from {values}",
    ].map do |template|
      Step template do |described, values|
        describe_positional_params values
        describe :instance, class_: described.resolve!( hierarchy ).subject
      end
    end
  
  
  CREATE_A_NEW_INSTANCE_WITH_NO_PARAMETERS,
  CONSTRUCT_AN_INSTANCE_WITH_NO_PARAMETERS = \
    [
      "I create a new instance of {class} with no parameters",
      "I construct an instance of {class} with no parameters",
    ].map do |template|
      Step template do |class_|
        describe :instance, class_: class_, params: Meta::Params.new
      end
    end
  
    
  CREATE_A_NEW_INSTANCE_OF_THE_DESCRIBED_WITH_NO_PARAMETERS,
  CONSTRUCT_AN_INSTANCE_OF_THE_DESCRIBED_WITH_NO_PARAMETERS = \
    [
      "I create a new instance of the {described} with no parameters",
      "I construct an instance of the {described} with no parameters",
    ].map do |template|
      Step template do |described|
        describe :instance,
          class_: described.resolve!( hierarchy ).subject,
          params: Meta::Params.new
      end
    end
  
end # module Instances

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
