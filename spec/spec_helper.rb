require 'cmds'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nrser'
require 'nrser/logger'

MAIN = self

LOG_LEVELS = {
  Logger::DEBUG => [:debug, 'DEBUG'],
  Logger::INFO => [:info, 'INFO'],
  Logger::WARN => [:warn, 'WARN'],
  Logger::ERROR => [:error, 'ERROR'],
  Logger::FATAL => [:fatal, 'FATAL'],
  Logger::UNKNOWN => [:unknown, 'UNKNOWN'],
}

BAD_LOG_LEVELS = [:blah, -1, 6, "BLAH"]

def expect_to_log &block
  expect(&block).to output.to_stderr_from_any_process
end

def expect_to_not_log &block
  expect(&block).to_not output.to_stderr_from_any_process
end