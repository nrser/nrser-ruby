source 'https://rubygems.org'

# Development versions

# gem 'yard-link_stdlib', path: "./dev/packages/gems/yard-link_stdlib"
# gem 'yard-nrser-cucumber', path: "./dev/packages/gems/yard-nrser-cucumber"

# Use local checkout of `nrser/yard` so I can play with stuff (not planning on
# making any permentant changes, but Git helps to track things)
# gem 'yard', path: './dev/packages/gems/yard'

unless ENV[ 'CI' ]
  gem 'yard-doctest', path: './dev/packages/gems/yard-doctest'
end

# Doesn't work, and not sure exactly what I want with it... going to sideline 
# it for now
# gem 'yard-typedef', path: File.join( ENV[ 'MY_GITHUB' ], 'yard-typedef' )

# Gems needed to support Ruby debugging in VSCode. Just export this ENV var
# somewhere to enable installation.
if ENV[ "VSCODE_RUBY_DEBUG" ]
  gem 'ruby-debug-ide', '>= 0.6.0'
  gem 'debase', '>= 0.2.1'
end

# Specify your gem's dependencies in nrser.gemspec
gemspec
