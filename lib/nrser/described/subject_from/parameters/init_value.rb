# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need to construct {Future}s
require_relative '../../resolution/future'

# Extends {Parameter}
require_relative "./parameter"


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
class   SubjectFrom


# Definitions
# =======================================================================


# @immutable
# 
class InitValue < Parameter
  
  prop :type, type: t.Type
  
  def initialize type
    initialize_props type: t.make( type )
  end
  
  def match? value
    return true if type.test? value
    
    # TODO  We *want* to be able to compare the {Described::Base.subject_type}
    #       to type to try to  find out if the subjects that `value` promises
    #       to produce will satisfy `type`, but {NRSER::Types} has essentially
    #       none of that functionality, and the general case is either 
    #       tremendously difficult or down-right impossible.
    #       
    #       So, for the moment at least, we just let it through since:
    #       
    #       1.  It was assigned at construction, so we're sure the user meant
    #           for its {Described::Base#subject} to be used.
    #           
    #       2.  If the subject is of the wrong type, we will catch it later.
    #
    return true if value.is_a? Described::Base
    
    # Otherwise, it's not a match.
    false
  end
  
  
  # @return [Future]
  #   
  # 
  # @return [nil]
  #   `object` will not resolve a value for this matcher now or in the future.
  # 
  def futurize object
    if type.test? object
      Resolution::Future.new value: object
      
    elsif object.is_a?( Described::Base )
      Resolution::Future.new \
        described: object, 
        method_name: :subject
      
    else
      nil
      
    end
  rescue Exception => error
    raise error
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  # A short string summary of the instance.
  # 
  # @return [::String]
  # 
  def to_s
    "#{ self.class }[ #{ described_class.to_s } ]"
  end
  
  
  # Override to just use {#to_s}, which is nice, short, and has what you need
  # to know.
  # 
  # @param [::PP] pp
  # @return [nil]
  # 
  def pretty_print pp
    pp.text to_s
    nil
  end
  
end # class InitValue


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
