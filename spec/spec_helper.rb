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

# So I can use `binding.pry` to drop into debugging
require 'pry'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser'
require 'nrser/refinements/types'
require 'nrser/rspex'

# Local Tree
# ----------------------------------------------------------------------------
require_relative './support/shared'


NRSER::Log.setup_for_rspec!


RSpec.configure do |config|
  unless ENV['LABS']
    config.filter_run_excluding labs: true
  end
  
  config.example_status_persistence_file_path = \
    NRSER::ROOT / 'tmp' / ".rspec_status"
    
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus
end


# Dumping ground for classes and modules that we need to create for tests.
# 
module NRSER::TestFixtures; end


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
