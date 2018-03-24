# Pre
# ============================================================================

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)


# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------
require 'cmds'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser'
require 'nrser/refinements/types'
require 'nrser/rspex'

# Local Tree
# ----------------------------------------------------------------------------
require_relative './support/shared'


RSpec.configure do |config|
  unless ENV['LABS']
    config.filter_run_excluding labs: true
  end
  
  config.example_status_persistence_file_path = \
    NRSER::ROOT / 'tmp' / ".rspec_status"
end


# Dumping ground for classes and modules that we need to create for tests.
# 
module NRSER::TestFixtures
  
  # module definition...
  
end # module NRSER::TestFixtures


# Was a part of old {NRSER::Logger} testing, keeping for a minute to see if
# need it again
# MAIN = self


if ENV['DEBUG']
  SemanticLogger.default_level = :debug
  SemanticLogger.add_appender(
    io: $stderr,
    formatter: { color: {ap: { multiline: true } }}
  )
end


def expect_to_log &block
  expect(&block).to output.to_stderr_from_any_process
end

def expect_to_not_log &block
  expect(&block).to_not output.to_stderr_from_any_process
end
