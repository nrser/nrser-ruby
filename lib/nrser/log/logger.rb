# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

require 'semantic_logger'


# Definitions
# =======================================================================

# Extension of {SemanticLogger::Logger} to add and customize behavior.
# 
class NRSER::Log::Logger < SemanticLogger::Logger
  
  # Classes
  # ========================================================================
  
  # Class that points to a {NRSER::Log::Logger} and provides the log methods
  # (`#error`, `#warn`, ... `#trace`) with an additional `&block` parameter.
  # 
  # Each of those methods calls the block in a `begin` / `rescue`, and if it
  # raises, the log message will be dispatched with the raised error added.
  # 
  # @see NRSER::Log::Logger#catch
  # 
  class Catcher
    
    # Construction
    # ========================================================================
    
    # Instantiate a new `Catcher`.
    # 
    # @param [NRSER::Log::Logger] logger
    #   The logger to use if the block raises.
    # 
    # @param [*] on_fail:
    #   Value to return when `&block` raises.
    # 
    def initialize logger, on_fail: nil
      @logger = logger
      @on_fail = on_fail
    end # #initialize
    
    
    # Instance Methods
    # ========================================================================
    
    SemanticLogger::LEVELS.each do |level|
      define_method level do |message = nil, payload = nil, &block|
        begin
          block.call
        rescue Exception => error
          @logger.send level, message, payload, error
          @on_fail
        end
      end
    end
    
  end # class Catcher
  
  
  # Attributes
  # ========================================================================
  
  # TODO document `awesome_name` attribute.
  # 
  # @return [String]
  #     
  attr_reader :awesome_name
  
  
  # Constructor
  # ========================================================================
  
  # Overrides {SemanticLogger::Logger#initialize}¹ to extend "subject" support
  # to instances (as well as modules/classes and strings).
  #
  # > ¹ {SemanticLogger::Logger#initialize} is just a proxy to
  # >   {SemanticLogger::Base#initialize}, which is what this implementation
  # >   is based off.
  # 
  # @param [Module | String | INSTANCE] subject
  #   Name of the class, module, or other identifier for which the log messages
  #   are being logged
  #
  # @param [nil | Symbol] level:
  #   Only allow log entries of this level or higher to be written to this
  #   appender For example if set to :warn, this appender would only log
  #   `:warn` and `:fatal` log messages when other appenders could be logging
  #   `:info` and lower.
  #
  # @param [nil | Regexp | Proc<(SemanticLogger::Log) => Boolean>] filter:
  #   1.  {RegExp}: Only include log messages where the class name matches
  #       the supplied regular expression. All other messages will be
  #       ignored.
  #       
  #   2.  {Proc}: Only include log messages where the supplied Proc returns
  #       `true`.
  #       
  # @raise [NRSER::TypeError]
  #   If `filter:` is not an acceptable type.
  # 
  def initialize subject, level: nil, filter: nil
    # Support filtering all messages to this logger using a Regular Expression
    # or Proc
    unless filter.nil? || filter.is_a?( Regexp ) || filter.is_a?( Proc )
      raise NRSER::TypeError,
        ":filter must be a Regexp or Proc",
        filter: filter,
        subject: subject,
        level: level
    end

    @filter = filter.is_a?(Regexp) ? filter.freeze : filter
    
    # @name   = klass.is_a?(String) ? klass : klass.name
    case subject
    when String
      @name = subject
      @awesome_name = subject
      @type = :string
      
    when Module
      @name = subject.safe_name
      @awesome_name = subject.ai multiline: true, raw: true
      @type = subject.is_a?( Class ) ? :class : :module
      
    else
      @name = subject.to_s
      @awesome_name = subject.ai multiline: true, raw: true
      @type = :instance
      
    end
    
    if level.nil?
      # Allow the global default level to determine this loggers log level
      @level_index = nil
      @level       = nil
    else
      self.level = level
    end
  end
  
  
  # Instance Methods
  # ========================================================================
  
  # A sweet way to try something and just log any {Exception}.
  # 
  # Useful for situations where the operation is question is not necessary
  # or can not be allowed to propagate errors, but you would like to record
  # and/or let the user know that it failed.
  # 
  # Create a new {Catcher} for this logger that defines the log methods
  # (`#error`, `warn`, ... `:trace`) to also accept blocks that will be
  # executed in a `begin`/`rescue`.
  # 
  # If the block raises, the catcher will call the log method, adding the
  # caught {Exception}.
  # 
  # @example Log any error as a warning
  #   logger.catch.warn do
  #     something_that_may_raise
  #   end
  #   
  #   # We should "always" get to here
  # 
  # @example Log any error as warning with message and payload
  #   logger.catch.warn(
  #     "This thing failed!",
  #     some_detail: some_value,
  #   ) do
  #     something_that_may_raise
  #   end
  #   
  #   # We should "always" get to here
  # 
  # @example Return a custom value on error
  #   result = logger.catch( on_fail: :blue ).debug do
  #     what_is_your_favorite_color?
  #   end
  # 
  # @param **options
  #   Passed to {Catcher#initialize}.
  # 
  # @return [Catcher]
  # 
  def catch **options
    Catcher.new self, **options
  end # #catch
  
  
  # Set the level for the execution of `&block`, restoring it to it's previous
  # level afterwards.
  # 
  # Like what {SemanticLogger::Logger#silence} does (which just forwards to
  # {SemanticLogger.silence}), but applies only to *this* logger (where as
  # {SemanticLogger::Logger#silence} applies on to the global default level).
  # 
  # Useful for quickly turning down the log level to see trace/debug output
  # from a specific section.
  # 
  # @param [Symbol?] level
  #   One of {SemanticLogger::LEVELS} or `nil` to use the global default level.
  # 
  # @param [Proc<() => RESULT] &block
  #   Block to execute with the `level`.
  # 
  # @return [RESULT]
  #   Whatever `&block` returns.
  # 
  def with_level level, &block
    prior_level = @level
    self.level = level
    
    begin
      block.call
    ensure
      self.level = prior_level
    end
  end
  
  
end # class NRSER::Log::Logger
