# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

# Need {::Cucumber::Glue::DSL.register_rb_hook} to register hooks
require 'cucumber/glue/dsl'

### Project / Package ###



# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

module Hooks
  
  def self.register!
    # ::Cucumber::Glue::Dsl.register_rb_hook \
    #   :after_step,
    #   [ '@imperative' ],
    #   ->( *args ) { hierarchy.resolve_all! }
    
    ::Cucumber::Glue::Dsl.register_rb_hook \
      :before,
      [ '@lazy' ],
      ->( *args ) { lazy! }
  end
  
end # module Hooks

# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
