# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

# Need {NRSER::LazyAttr} decorator.
require 'nrser/meta/lazy_attr'


# Namespace
# =======================================================================

module  NRSER
module  Log


# Definitions
# =======================================================================

# Abstraction to attempt to notify interactive users.
# 
module Notify
  
  +NRSER::LazyAttr
  # Is the `terminal-notifier` gem available?
  # 
  # [terminal-notifier][] is not an NRSER dependency since it does not make
  # sense for many systems and situations. It must be installed separately.
  # 
  # [terminal-notifier]: https://rubygems.org/gems/terminal-notifier
  # 
  # Tests by trying to `require` it.
  # 
  # @return [Boolean]
  # 
  def self.terminal_notifier?
    begin
      require 'terminal-notifier'
    rescue LoadError => error
      false
    else
      true
    end
  end # .terminal_notifier?
  
  
  +NRSER::LazyAttr
  # Can we send notification to the user?
  # 
  # Right now, only {.terminal_notifier?} is tested, but we can add more
  # options in the future.
  # 
  # @return [Boolean]
  # 
  def self.available?
    terminal_notifier?
  end # .available?
  
  
  # Send a notification to the use *if* notifications are {.available?}.
  # 
  # 
  def self.notify *args, &block
    return false unless available?
    
    notify! *args, &block
  end
  
  
  def self.notify! *args, &block
    require 'terminal-notifier'
    
    TerminalNotifier.notify *args, &block
  end
  
  
end # module Notify


# /Namespace
# =======================================================================

end # module Log
end # module NRSER
