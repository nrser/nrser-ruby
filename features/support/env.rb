# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

require 'thread'

### Deps ###

# Debug with `binding.pry
require 'pry'

### Project / Package ###

require 'nrser'

# Using {String#~} to squish string blocks
require 'nrser/core_ext/string/squiggle'

# Using truthy to test ENV vars
require 'nrser/ext/object/booly'


# Config
# =======================================================================

# Don't load pryrc - we went the env exactly how it is, and there's a huge mess
# of shit in there
Pry.config.should_load_rc = false

NRSER::Log.setup_for_cucumber!

unless ENV[ "FULL_TRACES" ].truthy?
  # Clean backtraces to make them easier to read
  
  require "nrser/ext/exception"

  NRSER::Ext::Exception.backtrace_cleaner = \
    { rel_paths: true, silence_gems: true }
end



$semaphore = Mutex.new

module Cucumber::StatusFile
  PATH = NRSER::ROOT.join 'tmp', '.cucumber_status.yaml'
  SEMAPHORE = Mutex.new
  
  def self.run_id
    Process.pid
  end
  
  
  def self.new
    {
      "run_id" => run_id,
      "failures" => [],
    }
  end
  
  
  def self.read
    status = YAML.load PATH.read
    
    if status[ "run_id" ] == run_id
      status
    else
      new
    end
  rescue
    new
  end
  
  
  def self.write &block
    SEMAPHORE.synchronize {
      status = read
      result = block.call status
      PATH.write YAML.dump( status )
      result
    }
  end
  
  
  def self.add_failure file_path
    write do |status|
      status[ "failures" ] << file_path
      status[ "failures" ].uniq!
    end
  end
  
end # module Cucumber::StatusFile


After &->( scenario ) do
  if scenario.failed?
    file_path = scenario.
      instance_variable_get( :@test_case ).
      location.file
    Cucumber::StatusFile.add_failure file_path
  end
end
