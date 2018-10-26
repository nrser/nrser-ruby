# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Using {String#squish}
require 'active_support/core_ext/string/filters'

# Project / Package
# ------------------------------------------------------------------------


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Exception

  # Method I use in the REPL to quickly get a "raised" version of a newly
  # created {::Exception} (one that will have a non-`nil` 
  # {::Exception#backtrace}).
  # 
  # @example
  #   RuntimeError.new( "Hey!" ).n_x._capture
  #   #=> #<RuntimeError: Hey!>
  # 
  # @return [Exception]
  #   `self` after having raised it.
  # 
  def _capture
    raise self
  rescue ::Exception => error
    error
  end


  # Format {::Exception#backtrace} for use in {#format}. Handles the case where
  # backtrace is `nil` (which it will be if it has never been raised).
  # 
  # @example {::Exception#backtrace} is an {Array}
  #   ( raise "Hello" rescue $! ).n_x.format_backtrace
  #   #=> "  (pry):3:in `__pry__'\n  /Users/nrser/src/gh/nrser/rash/dev/..."
  # 
  # @example {::Exception#backtrace} is `nil`
  #   RuntimeError.new( "Hello" ).n_x.format_backtrace
  #   #=> "  (NO BACKTRACE)"
  # 
  # @param [String] line_prefix
  #   Indent or other string to prefix each line with. Defaults to the `'  '`
  #   that Ruby uses when printing an unhandled exception.
  # 
  # @return [String]
  # 
  def format_backtrace line_prefix: '  '
    if backtrace
      line_prefix + backtrace.join( "\n#{ line_prefix }" )
    else
      "#{ line_prefix }(NO BACKTRACE)"
    end
  end


  # Format into a {::String} like how Ruby prints unhandled exceptions.
  # 
  # @example
  #   puts( (raise "Hello" rescue $!).n_x.format )
  #   # Hello (RuntimeError):
  #   #   (pry):11:in `__pry__'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:355:in `eval'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:355:in `evaluate_ruby'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:323:in `handle_line'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:243:in `block (2 levels) in eval'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:242:in `catch'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:242:in `block in eval'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:241:in `catch'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_instance.rb:241:in `eval'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:77:in `block in repl'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:67:in `loop'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:67:in `repl'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:38:in `block in start'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/input_lock.rb:61:in `__with_ownership'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/input_lock.rb:79:in `with_ownership'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:38:in `start'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/repl.rb:13:in `start'
  #   #   /Users/nrser/src/gh/nrser/rash/dev/packages/gems/nrser/.bundle/ruby/2.3.0/gems/pry-0.11.3/lib/pry/pry_class.rb:192:in `start'
  #   #   ./dev/bin/console:17:in `<main>'
  #   # => nil
  # 
  # @return [String]
  # 
  def format
    "#{ to_s } (#{ self.class }):\n#{ n_x.format_backtrace }"
  end
  
end # module Exception


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
