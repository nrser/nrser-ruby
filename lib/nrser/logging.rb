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
require_relative './logging/appender'


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
     
    def_single_delegators(
      SemanticLogger,
      :application,
      :application=,
      :[],
      # NOTE  These are funky due to different in SemLog's int level and Ruby
      #       stdlib / Rails logger int levels, so omit for now.
      #
      # :index_to_level,
      # :level_to_index
    )
    
    
    # Module Attributes
    # ============================================================================
    
    @__mutex = Mutex.new
    
    
    # Module (Class) Methods
    # =====================================================================
    
    # Normalize a level name or number to a symbol, raising if it's not valid.
    # 
    # Relies on Semantic Logger's "internal" {SemanticLogger.level_to_index}
    # method.
    # 
    # @see https://github.com/rocketjob/semantic_logger/blob/97247126de32e6ecbf74cbccaa3b3732768d52c5/lib/semantic_logger/semantic_logger.rb#L454
    # 
    # @param [Symbol | String | Integer]
    #   Representation of a level in one of the following formats:
    #   
    #   1.  {Symbol} - verified as member of {SemanticLogger::LEVELS} and
    #       returned.
    #    
    #   2.  {String} - accepts string representations of the level symbols,
    #       case insensitive.
    #   
    #   3.  {Integer} - interpreted as a Ruby StdLib Logger / Rails Logger
    #       level, which are **different** than Semantic Logger's!
    # 
    # @return [:trace | :debug | :info | :warn | :error | :fatal]
    #   Log level symbol.
    # 
    # @raise
    #   When `level` is invalid.
    # 
    def self.level_sym_for level
      if SemanticLogger::LEVELS.include? level
        level
      else
        SemanticLogger.index_to_level SemanticLogger.level_to_index( level )
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
    # @param level  (see .level_sym_for)
    # @return       (see .level_sym_for)
    # @raise        (see .level_sym_for)
    #   
    def self.level= level
      SemanticLogger.default_level = level_sym_for level
    end
    
    
    # Try to set the level, logging a warning and returning `nil` if it fails.
    # 
    # @param level (see .level=)
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
    end # .try_set_level
    
    
    def self.level_from_ENV prefix:
      if NRSER.truthy? ENV["#{ prefix }_TRACE"]
        return :trace
      elsif NRSER.truthy? ENV["#{ prefix }_DEBUG"]
        return :debug
      end
      
      level = ENV["#{ prefix }_LOG_LEVEL"]
      
      unless level.nil? || level == ''
        return level
      end
      
      nil
    end
    
    
    # Setup logging.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [nil]
    # 
    def self.setup! level: nil,
                    dest: nil,
                    sync: nil,
                    say_hi: :debug,
                    application: nil,
                    env_var_prefix: nil
      
      unless @__mutex.try_lock
        raise ThreadError, <<~END
          Mutex is already held.
          
          You should pretty generally NOT have multiple threads trying to
          setup logging at once or re-enter {NRSER::Logging.setup}!
        END
      end
      
      # Wrap around everything to make sure we release the mutex
      begin
        self.appender = dest unless dest.nil?
        
        # Set sync/async processor state
        self.sync = !!sync unless sync.nil?
        
        # If we didn't receive a level, check the ENV
        if level.nil?
          if env_var_prefix.nil?
            env_var_prefix = application.gsub( /[^a-zA-Z0-0_]+/, '_' ).upcase
          end
          
          level = level_from_ENV prefix: env_var_prefix
        end
        
        # If we ended up with a level, try to set it (will only log a warning
        # if it fails, not raise, which could crash things on boot)
        try_set_level level unless level.nil?
        
        self.application = application unless application.nil?
        
      ensure
        # Make sure we release the mutex; don't need to hold it for the rest
        @__mutex.unlock
      end
      
      will_say_hi = case say_hi
      when true, false
        say_hi
      when Symbol, String, Fixnum
        begin
          level_index < SemanticLogger.level_to_index( say_hi )
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
          dest: dest,
          sync: sync
      end
      
      nil
    rescue Exception => error
      # Suppress errors in favor of a warning
      
      logger.warn \
        message: "Error setting up logging",
        payload: {
          args: {
            level: level,
            dest: dest,
            env_var_prefix: env_var_prefix,
            say_hi: say_hi,
          },
        },
        exception: error
      
      nil
    end # .setup!
    
    
    # Call {.setup!} with some default keywords that are nice for CLI apps.
    # 
    # @param  (see .setup!)
    # @return (see .setup!)
    # 
    def self.setup_for_cli! dest: $stderr,
                            sync: true,
                            **kwds
      setup! dest: dest, sync: sync, **kwds
    end # .setup_for_cli!
    
    
    def self.sync?
      SemanticLogger::Processor.instance.is_a? NRSER::Logging::Appender::Sync
    end
    
    
    def self.sync= bool
      # Make sure we received a bool
      unless bool.equal?( true ) || bool.equal?( false )
        logger.warn "Expected arg to .sync= to be Boolean, skipping",
          arg: bool
        
        return nil
      end
      
      # Take no action if we're already in the desired state
      return bool if bool == sync?
      
      # Ok, need to make a change
      if sync?
        # Switch to async
        
        # We *should* already have the async processor
        @async_processor ||= SemanticLogger::Appender::Async.new(
          name:           'SemanticLogger::Processor',
          appender:       SemanticLogger::Processor.instance.appender,
          max_queue_size: -1,
        )
        
        @sync_processor ||= SemanticLogger::Processor.instance
        
        # Swap the async in for our sync
        SemanticLogger::Processor.instance_variable_set \
          :@processor,
          @async_processor
        
      else
        @async_processor ||= SemanticLogger::Processor.instance
        @sync_processor ||= NRSER::Logging::Appender::Sync.new \
          appender: SemanticLogger::Processor.instance.appender
        
        # Swap our sync in for the async
        SemanticLogger::Processor.instance_variable_set \
          :@processor,
          @sync_processor
      end
      
      bool
    end
    
    private_class_method :sync=
    
    
    # Hack up SemanticLogger to do sync logging in the main thread
    # 
    # @return [nil]
    # 
    def self.sync!
      # Create a {Locd::Logging::Appender::Sync}, which implements the
      # {SemanticLogger::Appender::Async} interface but just forwards directly
      # to it's appender in the same thread, and point it where
      # {SemanticLogger::Processor.instance} (which is an Async) points.
      # 
      sync_appender = NRSER::Logging::Appender::Sync.new \
        appender: SemanticLogger::Processor.instance.appender
      
      # Swap our sync in for the async
      SemanticLogger::Processor.instance_variable_set \
        :@processor,
        sync_appender
      
      nil
    end
    
    
    # The current "main" appender (destination), if any.
    # 
    # This is just to simplify things in simple cases, you can always still
    # add multiple appenders.
    # 
    # @return [SemanticLogger::Subscriber | nil]
    # 
    def self.appender
      @appender
    end
    
    
    def self.appender= value
      # Save ref to current appender (if any) so we can remove it after adding
      # the new one.
      old_appender = @appender
      
      @appender = case value
      when Hash
        SemanticLogger.add_appender value
      when String, Pathname
        SemanticLogger.add_appender file_name: value.to_s
      else
        SemanticLogger.add_appender \
          io: value,
          formatter: NRSER::Logging::Formatters::Color.new
      end
      
      # Remove the old appender (if there was one). This is done after adding
      # the new one so that failing won't result with no appenders.
      SemanticLogger.remove_appender( old_appender ) if old_appender
      
      @appender
    end
    
    private_class_method :appender=
    
    
  end # module Logging
end # module NRSER
