# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Subtree
require_relative './steps/attributes'
require_relative './steps/classes'
require_relative './steps/errors'
require_relative './steps/etc'
require_relative './steps/expectations'
require_relative './steps/methods'
require_relative './steps/modules'
require_relative './steps/objects'
require_relative './steps/parameters'
require_relative './steps/responses'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Submodules define (register) the {::Cucumber::Glue::StepDefinition}s (the
# normal Given, When and Then, which are all just aliases to the same thing).
#
module Steps
end # module Steps


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
