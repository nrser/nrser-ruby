# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/props/immutable/instance_variables'

# Need {Base} for prop types
require_relative './base'

# Need to construct {Future}s
require_relative './resolution/future'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

class From
  class ExtractError < StandardError; end

  class MatchExtractor
    include NRSER::Props::Immutable::InstanceVariables
    
    def self.from object
      if object.is_a?( MatchExtractor )
        object
        
      elsif object.is_a?( ::Class ) && object < Described::Base
        SubjectOf.new object
        
      else
        InputValue.new object
      end
    end
    
    
    # Proxies to {.new}. Lets you write nifty-er things like
    # 
    #     from From::ErrorOf[ Response ]
    # 
    # instead of oh so lame and easy to understand things like
    # 
    #     from From::ErrorOf.new( Response )
    # 
    # @return [self]
    #   A new one of this.
    # 
    def self.[] *args, &block
      new *args, &block
    end
  end
  
  
  class InputValue < MatchExtractor
    
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
    
  end # class InputValue
  
  
  class Resolvable < MatchExtractor
    
    # @!attribute [r] described_class
    #   The description class this match-extractor will match instances of.
    #   
    #   @return [::Class<Described::Base>]
    #   
    prop  :described_class,
          type: t.SubclassOf( Described::Base )
    
    
    # @!attribute [r] method_name
    #   Name of the method to use - `subject` or `error` - to extract the 
    #   value from resolved descriptions.
    #   
    #   @return [NRSER::Meta::Names::Method::Bare]
    #   
    prop  :method_name,
          type: t.IsA( NRSER::Meta::Names::Method::Bare )
    
    
    def initialize described_class, method_name
      initialize_props \
        described_class: described_class,
        method_name: NRSER::Meta::Names::Method::Bare.new( method_name )
    end
    
    
    def match? object
      object.is_a?( described_class ) ||
        described_class.subject_type.test?( object )
    end
    
    
    # @return [Future]
    # 
    # @return [nil]
    #   `object` will not resolve a value for this matcher now or in the future.
    # 
    def futurize object
      if object.is_a? Described::Base
        if object.is_a? described_class
          Resolution::Future.new \
            described: object,
            method_name: method_name.to_sym
        end
        
      elsif described_class.subject_type.test? object
        Resolution::Future.new value: object
        
      else
        nil
        
      end
    end
    
  end # class Resolvable
  
  
  class SubjectOf < Resolvable
    def initialize described_class
      super described_class, :subject
    end
  end # class SubjectOf
  
  
  class ErrorOf < Resolvable
    def initialize described_class
      super described_class, :error
    end
  end # class ErrorOf
  
  
  # Mixins
  # ==========================================================================
  
  include NRSER::Props::Immutable::InstanceVariables
  
  
  # Properties
  # =====================================================================
  
  # Principle Properties
  # ---------------------------------------------------------------------
  
  # @!attribute [r] types
  #   @todo Doc types property...
  #   
  #   @return [Hash<Symbol, MatchExtractor>]
  #   
  prop  :match_extractors,
        type: t.Hash( keys: t.Symbol, values: MatchExtractor )
  
  
  # @!attribute [r] init_block
  #   @todo Doc init_block property...
  #   
  #   @return [PropRubyType]
  #   
  prop  :init_block,
        type: t.IsA( Proc )
  
  
  # @todo Document type_for method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.type_for value
    if Base.subclass? value
      t.IsA value
    else
      t.make value
    end
  end # .type_for
  
  
  def initialize match_extractors:, init_block:
    initialize_props(
      match_extractors: match_extractors.
                          map { |k, v|
                            [ k.to_sym, MatchExtractor.from( v ) ]
                          }.
                          to_h,
      
      init_block: init_block,
    )
  end
  
  
end # class From

# /Namespace
# =======================================================================

end # module Described
end # module NRSER
