# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

# Besides just needing `pp` if you intend to do any pretty printing, we need
# it to make {::Object.pretty_print} calls
require 'pp'

### Deps ###

# Using {::Object#present?}
require 'active_support/core_ext/object/blank'

# Using {::String#truncate}
require 'active_support/core_ext/string/filters'

#### Sub-Tree ####
require_relative "./config/ivars"


# Namespace
# =======================================================================

module  NRSER
module  Support
module PP


# Definitions
# =======================================================================
  
class Config

  # Attributes
  # ==========================================================================
  
  # Instance variables config/processor, if any (`false` means don't add any
  # instance variables at all).
  # 
  # @return [false | IVars]
  #     
  attr_reader :ivars
  
  
  # Construction
  # ==========================================================================
  
  def initialize ivars: true, methods: false
    update! ivars: ivars, methods: methods
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  def update! **kwds
    set_ivars!( kwds[ :ivars ] ) if kwds.key?( :ivars )
    set_methods!( kwds[ :methods ] ) if kwds.key?( :methods )
    self
  end
  
  
  # @example
  #   
  #       NRSER::Support::PP::Config.new.set_ivars! \
  #           
  def set_ivars! arg
    @ivars = case arg
    when false, :never
      # If we're not going to include them at all, don't even bother creating
      # an {IVars} instance.
      false
    when true, :always, :present
      # Simple mode
      IVars.make mode: arg
    when ::Hash
      # Full config
      IVars.make **arg
    end
  end # #set_ivars!
  
  
  def set_methods! arg
    @methods = []
    
    if arg != false
      
      if arg.key? :always
        @methods += \
          arg[ :always ].
            map { |method_name| [ method_name.to_sym, :always ] }
      end
      
      if arg.key? :present
        @methods += \
          arg[ :present ].
            map { |method_name| [ method_name.to_sym, :present ] }
      end
      
      @methods.sort!
    end
    
    self
  end # #methods=
  
  
  def method_value_for instance, method_name
    instance.send method_name
    
  rescue Exception => error
    ErrorString.new "calling `.#{ method_name }`", error
    
  end # #method_value_for
  
  
  def values_for_methods instance, add_to: []
    add_to.tap do |values|
      @methods.each do |(method_name, include_when)|
        value = method_value_for instance, method_name
        
        if  include_when == :always ||
            ( include_when == :present && value.present? )
          values << [ method_name, value ]
        end
      end # @methods.each_with_object
    end # add_to.tap
  end
  
  
  def values_for instance, add_to: []
    add_to.tap do |values|
      ivars.values_for( instance, add_to: values ) if ivars
      values_for_methods instance, add_to: values
    end # [].tap |values|
  end # #values_for
  
end # class Config
  

# /Namespace
# =======================================================================

end # module PP
end # module Support
end # module NRSER

