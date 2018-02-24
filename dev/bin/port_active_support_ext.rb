#!/usr/bin/env ruby

require 'pathname'
require 'bundler/setup'

# /Users/nrser/dev/gh/nrser/qb/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/activesupport-5.1.4/lib/active_support/core_ext/hash/transform_values.rb

SHORT_OPTS = {
  'f' => :force,
}

PROJECT_ROOT = Pathname.new( '../../..' ).expand_path __FILE__
CORE_EXT = PROJECT_ROOT / '.bundle/ruby/2.3.0/gems/activesupport-5.1.4/lib/active_support/core_ext'
NRSER_EXT = PROJECT_ROOT / 'lib' / 'nrser' / 'ext'

def port_pattern pattern
  pattern = pattern + '.rb' unless pattern.end_with?( '.rb' )
  
  Pathname.glob( File.expand_path pattern, CORE_EXT ).each do |path|
    puts "Found file #{ path }"
    port_file path
  end
end

def port_file path
  rel = path.relative_path_from CORE_EXT
  
  class_dir, class_path = rel.to_s.split '/', 2
  
  dest = NRSER_EXT / class_dir / 'active_support' / class_path
  
  puts dest
  
end

def main *patterns, force: false
  $opts = {}
  
  patterns = []
  
  argv.each do |arg|
    if arg.start_with? '-'
      if arg.length == 2
        $opts[SHORT_OPTS.fetch arg[1]] = true
        
      elsif arg.start_with?( '--' )
        name, value = if arg.include? '='
          arg[2..-1].split '=', 2
        else
          [arg[2..-1], true]
        end
        
        $opts[name.to_sym] = value
        
      else
        raise "Bad opt: #{ arg.inspect }"
        
      end
    else
      patterns << arg
    end
  end
  
  puts "patterns: #{ patterns.inspect }"
  puts "options: #{ $opts.inspect }"
  
  patterns.each { |pattern| port_pattern pattern }
end

main ARGV
