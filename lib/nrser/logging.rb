# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------
require 'semantic_logger'

# Project / Package
# -----------------------------------------------------------------------
require_relative './logging/formatters'


# Definitions
# =======================================================================

module NRSER
  
  # Mix in {.logger} and {#logger} to NRSER for functions to use
  include SemanticLogger::Loggable
  
  # Unified logging support via {SemanticLogger}.
  # 
  # @see https://rocketjob.github.io/semantic_logger/index.html
  # 
  module Logging
    
    # Constants
    # ============================================================================
    
    # Include this guy in modules and classes to add `.logger` and `#logger` methods
    # that point to their own named logger.
    # 
    # Right now, just points to {SemanticLogger::Loggable}, but may expand on that
    # some time in the future, such as to add `.on`/`#on` methods like the old
    # `NRSER::Logger` had, etc.
    # 
    # @see http://www.rubydoc.info/gems/semantic_logger/SemanticLogger/Loggable
    # 
    # @return [Module]
    # 
    Mixin = SemanticLogger::Loggable
    
    
    # Mixins
    # ============================================================================
    
    # Mix in {.logger} and {#logger}
    include Mixin
    
    extend SingleForwardable
    
    
    # Delegation
    # ============================================================================
    
    def_single_delegators \
      SemanticLogger,
      :index_to_level,
      :level_to_index
    
    
    # Module Attributes
    # ============================================================================
    
    @__mutex = Mutex.new
    
    
    # Module (Class) Methods
    # =====================================================================
    
    
    def self.level_sym_for level
      if level.is_a? Symbol
        level
      else
        index_to_level level_to_index( level )
      end
    end
    
    
    # Global / default log level, which we always normalize to a symbol.
    # 
    # @return [:trace | :debug | :info | :warn | :error | :fatal]
    # 
    def self.level
      level_sym_for SemanticLogger.default_level
    end
    
    
    def self.level_index
      SemanticLogger.default_level_index
    end
    
    
    # Set the global default log level.
    # 
    # @param [Symbol | String | Fixnum] level
    #   Representation of a {#level} in one of the following formats:
    #   
    #   1.  {Symbol} - `:trace`, `:debug`, `:info`, `:warn`, `:error`
    #       or `:fatal`.
    #       
    #   2.  {String} - A string that when `#downcase`'d matches the `#to_s`
    #       of one of the symbols.
    #       
    #       > Example:
    #   
    def self.level= level
      SemanticLogger.default_level = level_sym_for level
    end
    
    
    # @todo Document try_level_to_index method.
    # 
    # @param level (see .level=)
    #   
    # 
    # @return [Symbol]
    #   The level symbol if it was set successfully.
    # 
    # @return [nil]
    #   If the set failed (also logs a warning).
    # 
    def self.try_set_level level
      begin
        self.level = level
      rescue Exception => error
        logger.warn "Unable to set level, probably bad value",
          level: level,
          error: error
        nil
      end
    end # .try_level_to_index
    
    
    
    # Setup logging.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [nil]
    # 
    def self.setup  level: nil,
                    dest: $stderr,
                    env_var_prefix: 'NRSER',
                    say_hi: :debug
      
      unless @__mutex.try_lock
        raise ThreadError, <<~END
          Mutext is already held.
          
          You should pretty generally NOT have multiple threads trying to
          setup logging at once or re-enter {NRSER::Logging.setup}!
        END
      end
      
      # Wrap around everything to make sure we release the mutext
      begin
        unless dest.nil?
          # Remove the appender if we already had one
          # 
          # TODO I guess this is a reasonable way to handle this?
          # 
          SemanticLogger.remove_appender( @appender ) if @appender
          
          # Create the appender and set the instance variable
          @appender = SemanticLogger.add_appender(
            io: dest,
            formatter: NRSER::Logging::Formatters::Color.new,
          )
        end
        
        # If we didn't receive a level, check the ENV
        if level.nil?
          level =   ENV["#{ env_var_prefix }_DEBUG"] ||
                    ENV["#{ env_var_prefix }_LOG_LEVEL"]
        end
        
        # If we ended up with a level, try to set it (will only log a warning
        # if it fails, not raise, which could crash things on boot)
        try_set_level level unless level.nil?
        
      ensure
        # Make sure we release the mutex; don't need to hold it for the rest
        @__mutex.unlock
      end
      
      will_say_hi = case say_hi
      when true, false
        say_hi
      when Symbol, String, Fixnum
        begin
          level_index < level_to_index( say_hi )
        rescue Exception => error
          logger.warn "Bad `say_hi` kwd in {NRSER::Logging.setup}",
            say_hi: say_hi,
            expected: "Symbol, String, or Fixnum representing log level",
            error: error
            
          false
        end
      else
        logger.warn "Bad `say_hi` kwd in {NRSER::Logging.setup}",
          say_hi: say_hi,
          expected: [true, false, Symbol, String, Fixnum]
        
        false
      end
      
      if will_say_hi
        logger.info "Hi! Logging is setup",
          level: self.level,
          dest: dest
      end
      
      nil
    rescue Exception => error
    end # .setup
    
  end # module Logging
end # module NRSER
