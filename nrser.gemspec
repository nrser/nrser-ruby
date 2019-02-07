# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nrser/version'

Gem::Specification.new do |spec|
  spec.name          = "nrser"
  spec.version       = NRSER::VERSION
  spec.authors       = ["nrser"]
  spec.email         = ["neil@neilsouza.com"]
  spec.summary       = %q{basic ruby utils i use in a lot of stuff.}
  spec.homepage      = "https://github.com/nrser/nrser.rb"
  spec.license       = "MIT"
  
  spec.required_ruby_version = '>= 2.3.0'

  spec.files         = Dir["lib/**/*.rb"] +
                        # "In-source" documentation files need to be packaged
                        # with the gem so that Yard `include` works on 
                        # rubydoc.org
                        Dir["lib/**/*.md"] +
                        %w(LICENSE.txt README.md)
  spec.executables   = [] # spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["spec/**/*.rb"]
  spec.require_paths = ["lib"]


  # Dependencies
  # ============================================================================
  
  # Runtime Dependencies
  # ----------------------------------------------------------------------------
  
  # Persistent (immutable) collections
  spec.add_dependency 'hamster', '~> 3.0'
  
  # Much better logging
  # 
  # TODO  4.4 breaks {NRSER::Log}, need to figure that out. For the moment, just
  #       say we need less than that.
  spec.add_dependency 'semantic_logger', '>= 4.2', '< 4.4'

  # With much more awesome printing!
  spec.add_dependency 'awesome_print', '~> 1.8'
  
  # Style strings for the terminal
  spec.add_dependency 'pastel', '~> 0.7.2'
  
  # Commonmark (new standardized GFM) Ruby implementation that GH is suggesting
  # 
  # Using it to parse strings and style them for the terminal
  # 
  spec.add_dependency 'commonmarker', '~> 0.17.9'
  
  # All sorts of goodies (and monkey business)
  spec.add_dependency 'activesupport', '~> 5.1'
  
  # Python-like method decorators (one part of Python I really still like!)
  spec.add_dependency 'method_decorators', '~> 0.9.6'
  
  # Development Dependencies
  # ----------------------------------------------------------------------------

  spec.add_development_dependency "bundler", '>= 1.16.1'
  spec.add_development_dependency "rake", '~> 12.3'
  
  # Testing with `rspec`
  spec.add_development_dependency "rspec", '~> 3.7'
  
  # Trying out the cuc'...
  spec.add_development_dependency "cucumber", '~> 3.1.0'
  spec.add_development_dependency "aruba", '~> 0.14.6'
  spec.add_development_dependency 'yard-nrser-cucumber', '> 0.0.0'
  
  # Doc site generation with `yard`
  spec.add_development_dependency 'yard', '~> 0.9.15'
  
  # GitHub-Flavored Markdown (GFM) for use with `yard`
  spec.add_development_dependency 'github-markup', '~> 2.0.1'
  
  # Provider for `commonmarker`, the new GFM lib
  spec.add_development_dependency 'yard-commonmarker', '~> 0.5.0'

  spec.add_development_dependency 'yard-link_stdlib', '~> 0.1.0'
  
  # Add my `yard clean` command
  spec.add_development_dependency 'yard-clean', '~> 0.1.0'
  
  # Nicer REPL experience
  spec.add_development_dependency "pry", '~> 0.12.2'

  # Supposed to drop into pry as a debugger on unhandled exceptions, but I 
  # haven't gotten to test it yet
  spec.add_development_dependency "pry-rescue", '~> 1.5'

  # Move around the stack when you debug with `pry`, really sweet
  spec.add_development_dependency "pry-stack_explorer", '~> 0.4.9'
  
  # My system commands lib
  spec.add_development_dependency "cmds", '~> 0.2.11'

  # Used to parse docs from the Quip API - at the moment, the {NRSER::Types}
  # display table, which we verify in the specs
  spec.add_development_dependency "nokogiri", '~> 1.8.4'

  spec.add_development_dependency "mongo", '~> 2.6.1'
  
end
