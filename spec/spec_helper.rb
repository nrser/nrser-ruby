$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nrser'
require 'nrser/logger'

LOG_LEVELS = {
  Logger::DEBUG => [:debug, 'DEBUG'],
  Logger::INFO => [:info, 'INFO'],
  Logger::WARN => [:warn, 'WARN'],
  Logger::ERROR => [:error, 'ERROR'],
  Logger::FATAL => [:fatal, 'FATAL'],
  Logger::UNKNOWN => [:unknown, 'UNKNOWN'],
}

BAD_LOG_LEVELS = [:blah, -1, 6, "BLAH"]