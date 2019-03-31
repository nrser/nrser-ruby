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

gemroot = File.expand_path '../..', __dir__

# Render text from Cucumber features using the same markup (Commonmark) as the
# rest of things
YARD::Config.options[ :'yard-cucumber.markup' ] = :default

YARD::Templates::Engine.register_template_path \
  File.join( __dir__, "templates" )


if ENV['NRSER_PRY']
  require 'pry'
  
  # Don't load pryrc - we went the env exactly how it is, and there's a huge mess
  # of shit in there
  Pry.config.should_load_rc = false
  
  # Disable progress printing, which screws up using Pry
  log.show_progress = false
end


# YARD::Tags::Library.define_tag "Testees", :test, :with_types
