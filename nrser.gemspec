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
  spec.homepage      = "https://github.com/nrser/nrser-ruby"
  spec.license       = "MIT"
  
  spec.required_ruby_version = '>= 2.3.0'

  spec.files         = Dir["lib/**/*.rb"] + %w(LICENSE.txt README.md)
  spec.executables   = [] # spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["spec/**/*.rb"]
  spec.require_paths = ["lib"]


  # Dependencies
  # ============================================================================
  
  # Development Dependencies
  # ----------------------------------------------------------------------------

  spec.add_development_dependency "bundler",        '~> 1.16', '>= 1.16.1'
  spec.add_development_dependency "rake",           '~> 12.3'
  
  # Testing with `rspec`
  spec.add_development_dependency "rspec",          '~> 3.7'
  
  # Doc site generation with `yard`
  spec.add_development_dependency "yard",           '~> 0.9.12'
  
  # These, along with `//.yardopts` config, are *supposed to* result in
  # rendering markdown files and doc comments using
  # GitHub-Flavored Markdown (GFM), though I'm not sure if it's totally working
  spec.add_development_dependency "redcarpet",      '~> 3.4'
  spec.add_development_dependency "github-markup",  '~> 1.6'
  
  # Nicer REPL experience
  spec.add_development_dependency "pry",            '~> 0.10.4'
  
  # My system commands lib
  spec.add_development_dependency "cmds",           '~> 0.0', '>= 0.2.4'
end
