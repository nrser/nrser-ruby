# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Meta::Names::Const.pattern}
require 'nrser/meta/names'

require 'nrser/meta/args/array'

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
  
  
  # def_step_component :from_arguments,
  #   "from/with", Arguments.components[ :arguments ]
  
  
  # def_step_component :named_class,
  #   "{class}" \
  # do |class_|
  #   class_
  # end
  
  
  # def_step_component :described_class,
  #   "the {described}" \
  # do |described|
  #   described.resolve!( hierarchy ).subject
  # end
  
  
  # def_step_component :class,
  #   components[ :named_class ] | components[ :described_class ]
  
  
  # def_step_component :construct_from,
  #   "I construct a(n) (instance of )",
  #   components[ :class ],
  #   "from/with",
  #   Arguments.components[ :arguments ]
  
  
  # Steps
  # ==========================================================================
  
  AN_INSTANCE = \
    Step "an instance:" do |source|
      describe :instance, subject: eval( source )
    end
  
  
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
        describe_positional_args values
        describe :instance, class_: described.resolve!( hierarchy ).subject
      end
    end
    
    
  CREATE_A_NEW_INSTANCE_FROM,
  CONSTRUCT_AN_INSTANCE_FROM = \
    [
      "I create a new instance of {class} from {values}",
      "I construct an instance of {class} from {values}",
    ].map do |template|
      Step template do |class_, values|
        describe_positional_args values
        describe :instance, class_: class_
      end
    end
  
  
  CREATE_A_NEW_INSTANCE_WITH_NO_ARGS,
  CONSTRUCT_AN_INSTANCE_WITH_NO_ARGS = \
    [
      "I create a new instance of {class} with no arguments",
      "I construct an instance of {class} with no arguments",
    ].map do |template|
      Step template do |class_|
        describe :instance,
          class_: class_,
          args: Meta::Args::Array.new
      end
    end
  
    
  CREATE_A_NEW_INSTANCE_OF_THE_DESCRIBED_WITH_NO_ARGS,
  CONSTRUCT_AN_INSTANCE_OF_THE_DESCRIBED_WITH_NO_ARGS = \
    [
      "I create a new instance of the {described} with no arguments",
      "I construct an instance of the {described} with no arguments",
    ].map do |template|
      Step template do |described|
        describe :instance,
          class_: described.resolve!( hierarchy ).subject,
          args: Meta::Args::Array.new
      end
    end
  
end # module Instances


# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
