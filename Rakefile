# encoding: UTF-8
# frozen_string_literal: true

require 'shellwords'

# Has `release` task
require "bundler/gem_tasks"

# Loads the {RSpec::Core::RakeTask} used below
require "rspec/core/rake_task"

# Load up cucumber tasks
require 'cucumber'
require 'cucumber/rake/task'


# Tasks
# ============================================================================

# Add `spec` task to run RSpec
RSpec::Core::RakeTask.new :spec


# Add `features` task to run Cucumber
Cucumber::Rake::Task.new :features do |t|
  t.cucumber_opts = "--format pretty"
end


desc %(Run `yard doctest` on all lib Ruby files with `# doctest: true` comment)
task :doctest do
  paths = Dir[ './lib/**/*.rb' ].select do |path|
    File.open( path, 'r' ).each_line.lazy.take( 32 ).find do |line|
      line.start_with? '# doctest: true'
    end
  end
  
  sh %(yard doctest #{ paths.shelljoin })
end # task :doctest


task :default => [ :spec, :features, :doctest ]
