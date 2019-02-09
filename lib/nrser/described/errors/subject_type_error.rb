# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

require 'nrser/types'


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# @todo document SubjectType class.
# 
class SubjectTypeError < Types::CheckError
  
  # Attributes
  # ==========================================================================
  
  # The description the subject was for.
  # 
  # @return [Described::Base]
  #     
  attr_reader :described
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `SubjectType`.
  def initialize *description, described:, subject:, resolution: nil
    @described = described
    
    context = {
      value: subject,
      type: described.class.subject_type,
    }
    
    unless resolution.nil?
      # TODO  This is better than nothing, and stays somewhat brief, but could
      #       be improved...
      context[ :resolution ] = \
        resolution.subject_from.parameters.map { |name, parameter|
          [ name, { parameter: parameter, value: resolution.values[ name ], } ]
        }.to_h
    end
    
    super( context )
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  def subject
    value
  end
  
  
  def default_message
    [ "Subject ({#value}) failed to satisfy",
      described.class.method( :subject_type ),
      "({#type})", ]
  end
  
end # class SubjectTypeError


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
