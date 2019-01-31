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
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new {MultipleErrors}.
  # 
  # @param [Exception] cause
  #   The error to wrap.
  # 
  def initialize *message, cause:, **kwds
    unless cause.is_a? Exception
      raise NRSER::TypeError.new \
        "`cause` for {NRSER::WrappedError} must be an {Exception}, found",
        cause,
        cause: cause
    end
  
    @cause = cause
    
    # Pass to {NRSER::NicerError#initialize}
    super *message, **kwds
  end # #initialize


  # Instance Methods
  # ========================================================================

  def default_details
    "Cause: " +  cause.n_x.format.n_x.indent( 4, skip_first_line: true )
  end

  
end # class WrappedError


# /Namespace
# =======================================================================

end # module NRSER
