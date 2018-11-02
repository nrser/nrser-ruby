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

# Using {NRSER::Ext::Enumerable#count_by}
require 'nrser/ext/enumerable'

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
class MultipleErrors < StandardError

  # Mixins
  # ========================================================================

  include NicerError

  
  # Attributes
  # ======================================================================
  
  # The individual errors that occurred.
  # 
  # @return [Enumerable<Exception>]
  #     
  attr_reader :errors
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new {MultipleErrors}.
  # 
  # @param [Enumerable<Exception>] errors
  #   The individual errors.
  # 
  def initialize *message, errors:, **kwds
    @errors = errors
    
    # Pass to {NRSER::NicerError#initialize}
    super *message, **kwds
  end # #initialize


  # Instance Methods
  # ========================================================================

  def default_message
    class_counts = errors.n_x.count_by( &:class ).
      map { |klass, count| "#{ klass } (#{ count })" }.
      sort.
      join( ', ' )
    
    "#{ errors.count } error(s) occurred - #{ class_counts }"
  end


  def default_details
    errors.
      each_with_index.
      map { |error, index|
        (index.succ.to_s + '.').ljust( 4 ) +
          error.n_x.format.n_x.indent( 4, skip_first_line: true )
      }.
      join( "\n    \n" ) + "\n"
  end

  
end # class MultipleErrors


# /Namespace
# =======================================================================

end # module NRSER
