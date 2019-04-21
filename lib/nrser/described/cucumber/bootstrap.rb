# encoding: UTF-8
# frozen_string_literal: true
# 
##############################################################################
# Bootstrap {NRSER::Described} for Cucumber
# ============================================================================
# 
# Connects {NRSER::Described} into Cucumber.
# 
# Require this file in your `features/env/described.rb` or equivalent.
# 
##############################################################################

require 'nrser/described'

require_relative './parameter_types'
require_relative './world'
require_relative './hooks'

World NRSER::Described::Cucumber::World::Logger
World NRSER::Described::Cucumber::World::Describe
World NRSER::Described::Cucumber::World::Expect
World NRSER::Described::Cucumber::World::Scope
World NRSER::Described::Cucumber::World::Quote

NRSER::Described::Cucumber::ParameterTypes.register!
NRSER::Described::Cucumber::Hooks.register!

require_relative './steps'
