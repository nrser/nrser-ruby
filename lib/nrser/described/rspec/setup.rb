##############################################################################
# Setup {NRSER::Described::Rspec} in an RSpec Environment
# ============================================================================
# 
# This file does stuff, including heavily modifying the global environment.
# 
# Require it when you're in an `rspec` process.
# 
##############################################################################

require 'nrser/described'

require 'nrser/described/rspec'

require_relative './example_group'
require_relative './example'
require_relative './shared_examples'
require_relative './top_level_mixin'

::RSpec.configure do |config|
  config.extend   NRSER::Described::RSpec::ExampleGroup
  config.include  NRSER::Described::RSpec::Example
  
  config.add_setting :x_type_prefixes
  config.x_type_prefixes = \
    NRSER::Described::RSpec::Format::PREFIXES
  
  config.add_setting :x_style, default: :esc_seq
end

# Make "describe" methods available at the top-level
include NRSER::Described::RSpec::TopLevelMixin

require 'pry'
Pry.config.should_load_rc = false
# binding.pry
