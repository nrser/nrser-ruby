# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

require "active_support/backtrace_cleaner"

### Project / Package ###


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Meta


# Definitions
# =======================================================================

class BacktraceCleaner < ActiveSupport::BacktraceCleaner
  def initialize rel_paths: false, silence_gems: false
    super()
    
    if silence_gems
      add_silencer { |line|
        Gem.paths.path.any? { |gem_path|
          line.start_with?( gem_path ) ||
            ( rel_paths &&
              gem_path.start_with?( Dir.getwd ) &&
              line.start_with?( gem_path.sub Dir.getwd, '.' ) )
        }
      }
    end
    
    if rel_paths
      add_filter { |line| line.gsub Dir.getwd, '.' }
    end
    
  end
end # class BacktraceCleaner


# /Namespace
# =======================================================================

end # module Meta
end # module NRSER

