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

# Including {NicerError}
require_relative './nicer_error'

# Using {NRSER::Ext::String#indent}
require 'nrser/ext/string/text'

# Using {NRSER::Ext::Exception#format}
require 'nrser/ext/exception'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# A wrapper error around a list of other errors.
# 
class WrappedError < ::StandardError

  # Mixins
  # ========================================================================

  include NicerError

  
  # Attributes
  # ======================================================================
  
  # The wrapped error.
  # 
  # @return [Exception]
  #     
  attr_reader :cause
  
  
  # Optional backtrace cleaner to use when formatting the {#cause}.
  # 
  # @return [ActiveSupport::BacktraceCleaner?]
  #     
  attr_reader :backtrace_cleaner
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new {MultipleErrors}.
  # 
  # @param [Exception] cause
  #   The error to wrap.
  # 
  def initialize *message, cause:, backtrace_cleaner: nil, **kwds
    unless cause.is_a? Exception
      raise NRSER::TypeError.new \
        "`cause` for {NRSER::WrappedError} must be an {Exception}, found",
        cause,
        cause: cause
    end
  
    @cause = cause
    @backtrace_cleaner = backtrace_cleaner
    
    # Pass to {NRSER::NicerError#initialize}
    super *message, **kwds
  end # #initialize


  # Instance Methods
  # ========================================================================

  def default_details
    "Cause:\n" +  \
      cause.
        n_x.format( backtrace_cleaner: backtrace_cleaner ).
        n_x.indent( 4, skip_first_line: false )
  end

  
end # class WrappedError


# /Namespace
# =======================================================================

end # module NRSER
