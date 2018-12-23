# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Per-feature dynamically created "scenario scope" modules are set as
# uniquely-named constants of this module, allowing them to "naturally" receive
# and report that name.
#
# Yeah, this module could also just be created dynamically, but I think it's
# nice to have it here on account of this documentation.
#
# Check out {World::Scope} for the methods that create and interact with scope
# modules.
#
# @see ::NRSER::Described::Cucumber::World::Scope
#
module ScenarioScopes
end # module ScenarioScopes


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER