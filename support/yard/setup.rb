##############################################################################
# Custom YARD Setup Script
# ============================================================================
#
# This file is loaded when running `yard` via the `--load` CLI option, through a
# line in `//.yardopts`.
# 
# It's here to perform custom configuration by interacting with the YARD API
# directly in Ruby.
#
##############################################################################

require 'yard'

# Render text from Cucumber features using the same markup (Commonmark) as the
# rest of things
YARD::Config.options[ :'yard-cucumber.markup' ] = :default


# if ENV['NRSER_PRY']
#   require 'pry'
  
#   # Don't load pryrc - we went the env exactly how it is, and there's a huge mess
#   # of shit in there
#   Pry.config.should_load_rc = false
  
#   binding.pry
# end

# YARD::Tags::Library.define_tag "Testees", :test, :with_types
