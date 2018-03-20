# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------
require 'awesome_print'
require 'semantic_logger'

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER::Logging; end
module NRSER::Logging::Formatters; end


# Definitions
# =======================================================================

class NRSER::Logging::Formatters::Color < ::SemanticLogger::Formatters::Color
  
  # Constants
  # ======================================================================
  
  # ANSI escape sequence to start "Dark Gray" color.
  # 
  # @return [String]
  # 
  ANSI_ESC_DARK_GRAY = "\e[1;30m"
  
  
  # Class Methods
  # ======================================================================
  
  # @todo Document default_color_map method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [SemanticLogger::Formatters::Color::ColorMap]
  # 
  def self.default_color_map
    SemanticLogger::Formatters::Color::ColorMap.new(
      debug: SemanticLogger::AnsiColors::MAGENTA,
      trace: ANSI_ESC_DARK_GRAY,
    )
  end # .default_color_map
  
  
  # Attributes
  # ======================================================================
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `ColorFormatter`.
  def initialize  ap: {multiline: true},
                  color_map: self.class.default_color_map,
                  time_format: ::SemanticLogger::Formatters::Base::TIME_FORMAT,
                  log_host: false,
                  log_application: false
    super ap: ap,
          color_map: color_map,
          time_format: time_format,
          log_host: log_host,
          log_application: log_application
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  
  # Upcase the log level.
  # 
  # @return [String]
  # 
  def level
    "#{ color }#{ log.level.upcase }#{ color_map.clear }"
  end
  
  
  # Create the log entry text. Overridden to customize appearance -
  # generally reduce amount of info and put payload on it's own line.
  # 
  # We need to replace *two* super functions, the first being
  # [SemanticLogger::Formatters::Color#call][]:
  # 
  #     def call(log, logger)
  #       self.color = color_map[log.level]
  #       super(log, logger)
  #     end
  # 
  # [SemanticLogger::Formatters::Color#call]: https://github.com/rocketjob/semantic_logger/blob/v4.2.0/lib/semantic_logger/formatters/color.rb#L98
  # 
  # which doesn't do all too much, and the next being it's super-method,
  # [SemanticLogger::Formatters::Default#call][]:
  #     
  #     # Default text log format
  #     #  Generates logs of the form:
  #     #    2011-07-19 14:36:15.660235 D [1149:ScriptThreadProcess] Rails -- Hello World
  #     def call(log, logger)
  #       self.log    = log
  #       self.logger = logger
  #     
  #       [time, level, process_info, tags, named_tags, duration, name, message, payload, exception].compact.join(' ')
  #     end
  # 
  # [SemanticLogger::Formatters::Default#call]: https://github.com/rocketjob/semantic_logger/blob/v4.2.0/lib/semantic_logger/formatters/default.rb#L64
  # 
  # which does most the real assembly.
  # 
  # @param [SemanticLogger::Log] log
  #   The log entry to format.
  #   
  #   See [SemanticLogger::Log](https://github.com/rocketjob/semantic_logger/blob/v4.2.0/lib/semantic_logger/log.rb)
  # 
  # @param [SemanticLogger::Logger] logger
  #   The logger doing the logging (pretty sure, haven't checked).
  #   
  #   See [SemanticLogger::Logger](https://github.com/rocketjob/semantic_logger/blob/v4.2.0/lib/semantic_logger/logger.rb)
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def call log, logger
    # SemanticLogger::Formatters::Color code
    self.color = color_map[log.level]
    
    # SemanticLogger::Formatters::Default code
    self.log    = log
    self.logger = logger
    
    [
      time, # annoyingly noisy and don't really need for local CLI app
      level,
      process_info,
      tags,
      named_tags,
      duration,
      name,
    ].compact.join( ' ' ) +
    "\n" +
    [
      message,
      payload,
      exception,
    ].compact.join(' ') +
    "\n" # I like extra newline to space shit out
    
  end # #call
  
  
end # class Color
